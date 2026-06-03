# Accuracy on test: 0.7863
"""task2_solution.py - решение тестового задания (ML).
Подробный ход решения есть в файле solution.ipynb.
"""

import numpy as np
import pandas as pd
from sklearn.datasets import fetch_openml
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.preprocessing import OneHotEncoder

RANDOM_STATE = 42


def load_data() -> pd.DataFrame:
    """Загружаю данные из датасета.
    Если сайт не работает, загружаю файлом.
    """
    try:
        df = fetch_openml("titanic", version=1, as_frame=True).frame
        return df
    except Exception:
        df = pd.read_csv('titanic_openml.csv')
        return df


def extract_title(name_series: pd.Series) -> pd.Series:
    """Извлекаю титулы людей из колонки name.
    Титул кодирует пол, возраст и социальный статус человека.
    Редкие титулы объединяю в группы, чтобы избежать переобучения.
    """
    title = name_series.str.extract(r',\s*([^\.]+)\.')[0]
    mapping = {
        "Mlle": "Miss", "Ms": "Miss", "Mme": "Mrs",
        "Sir": "Mr", "Don": "Mr", "Jonkheer": "Mr",
        "the Countess": "Mrs", "Lady": "Mrs", "Dona": "Mrs",
        "Dr": "Officer", "Rev": "Officer", "Col": "Officer",
        "Major": "Officer", "Capt": "Officer",
    }
    return title.replace(mapping)


def preprocess(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    """Препроцессинг датасета.
    Решения:
    - boat/body - дропаю. утечка данных (data leakage).
      boat есть только у выживших, body только у погибших.
    - cabin/home.dest/ticket - дропаю: высококардинальные,
      cabin почти пуст (1014 пропусков).
    - pclass/sibsp/parch - конвертирую в int8 (значения целочисленные и маленькие, экономлю память).
    - title - получаю из name, кодирует пол, возраст и статус человека.
    - sex - label encoding (male=1, female=0).
    - family_size = parch + sibsp + 1 - размер семьи на борту.
    - is_alone - бинарный флаг одиночного путешествия.
    - sibsp/parch - дропаю после создания family_size.
    """
    df = df.copy()

    df = df.drop(["boat", "body"], axis=1) #утечки данных
    df = df.drop(["cabin", "home.dest", "ticket"], axis=1) #шумные/высококардинальные
    for col in ["pclass", "sibsp", "parch"]:
        df[col] = pd.to_numeric(df[col], downcast="integer")

    df["title"] = extract_title(df["name"]) #получаю титул
    df["family_size"] = df["parch"] + df["sibsp"] + 1 #считаю размер семьи
    df["is_alone"] = (df["family_size"] == 1).astype(int) #получаю флаг одиночного путешествия
    df["sex"] = df["sex"].map({"male": 1, "female": 0}) #бинарно кодирую
    df = df.drop(["parch", "sibsp"], axis=1)

    X = df.drop(["survived", "name"], axis=1)
    y = df["survived"].astype(int)
    return X, y


def impute(X_train: pd.DataFrame, X_test: pd.DataFrame):
    """Заполняю пропуски параметрами обученными только на X_train.

    age: медиана по титулу - пассажиры одного титула близки по возрасту.
    fare: медиана по классу и порту - эти факторы сильнее всего влияют на цену.
    embarked: мода (2 пропуска из 1307) - беру самое часто встречающее значение.

    Все параметры считаются на train и применяются к test - исключаю утечку данных через импутацию.
    """

    age_by_title = X_train.groupby("title")["age"].median() #age по титулу
    for ds in [X_train, X_test]:
        mask = ds["age"].isna()
        ds.loc[mask, "age"] = ds.loc[mask, "title"].map(age_by_title)

    fare_median = X_train.groupby(["pclass", "embarked"], observed=True)["fare"].median() #fare по классу и порту
    for ds in [X_train, X_test]:
        mask = ds["fare"].isna()
        ds.loc[mask, "fare"] = ds.loc[mask, ["pclass", "embarked"]].apply(
            lambda r: fare_median.get((r["pclass"], r["embarked"])), axis=1
        )

    embarked_mode = X_train["embarked"].mode()[0] #embarked - мода
    X_train["embarked"] = X_train["embarked"].fillna(embarked_mode)
    X_test["embarked"] = X_test["embarked"].fillna(embarked_mode)

    return X_train, X_test


def encode(X_train: pd.DataFrame, X_test: pd.DataFrame):
    """OHE для категориальных признаков.
    OHE обучается только на train (handle_unknown='ignore').
    """
    categorical_cols = ["embarked", "title"]
    ohe = OneHotEncoder(handle_unknown="ignore", sparse_output=False)
    ohe.fit(X_train[categorical_cols])

    cols = ohe.get_feature_names_out(categorical_cols)
    X_train_ohe = pd.DataFrame(
        ohe.transform(X_train[categorical_cols]), columns=cols, index=X_train.index
    )
    X_test_ohe = pd.DataFrame(
        ohe.transform(X_test[categorical_cols]), columns=cols, index=X_test.index
    )

    X_train = X_train.drop(categorical_cols, axis=1).join(X_train_ohe)
    X_test = X_test.drop(categorical_cols, axis=1).join(X_test_ohe)
    return X_train, X_test


def main():
    df = load_data()
    X, y = preprocess(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_STATE
    )

    X_train, X_test = impute(X_train, X_test)
    X_train, X_test = encode(X_train, X_test)

    #подбираю гиперпараметры через GridSearchCV
    param_grid = {
        "n_estimators": [150, 300, 500],
        "max_depth": [3, 5, 7, 10],
        "min_samples_leaf": [4, 6, 8, 12],
        "criterion": ["gini", "entropy"],
    }
    grid_search = GridSearchCV(
        estimator=RandomForestClassifier(random_state=RANDOM_STATE),
        param_grid=param_grid,
        cv=5,
        scoring="accuracy",
        n_jobs=-1,
    )
    grid_search.fit(X_train, y_train)

    acc = accuracy_score(y_test, grid_search.best_estimator_.predict(X_test)) #оценка лучшей модели
    print(f"Accuracy on test: {acc:.4f}")


if __name__ == "__main__":
    main()