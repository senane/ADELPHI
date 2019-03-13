from __future__ import absolute_import, division, print_function
from matplotlib.font_manager import _rebuild; _rebuild()
import tensorflow as tf
import re
#Helper libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io as spio
from keras.models import Sequential
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasClassifier
from keras.utils import np_utils
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import LabelEncoder
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from  sklearn.metrics import precision_recall_fscore_support
from sklearn.metrics import roc_curve, auc
from sklearn.preprocessing import LabelBinarizer
from yellowbrick.classifier import ConfusionMatrix
import seaborn as sn
import random
tf.logging.set_verbosity(tf.logging.INFO)

"""Load the dataset and set randomness."""

# Initialize random number generator for reproducibility.
seed = 7
np.random.seed(seed)

# Load in dataset.
data = spio.loadmat("features_10s_2019-01-30.mat");
features = data['features'];
labels = data['labels_features'];
animal_id_features = data['animal_id_features'].transpose();
feat_names = data['feat_names']
col_names = pd.DataFrame(feat_names)
# Label each feature column with its description.
def find_between(s):
    start = '\'';
    end = '\'';
    return((s.split(start))[1].split(end)[0])
cols = [];
c_names = col_names.values.ravel();

for x in range(len(c_names)):
    name = str (c_names[x]);
    cols.append(find_between(name))

# Create a DataFrame of features with columns named & rows labeled.
feat_data = pd.DataFrame(data=features,columns=cols)
feat_data.insert(0,'AnimalId',animal_id_features)
feat_data.insert(0,'Labels',labels.transpose())

# Randomly select an animal to leave out.
index = random.randint(1,12);
# Select the features corresponding to one animal.
def get_single_animal_features(df, index) :
    return df.loc[df['AnimalId'] == index]

# Delete the rows corresponding to the animal left out.
def get_loo_features(df, index):
    df.set_index('AnimalId')
    df.data.drop(index, axis=0)
    return df

# Get features of 11/12 animals.
single_animal_features = get_single_animal_features(feat_data, index);
loo_features = get_loo_features(feat_data, index);

# Get only labels corresponding to first animal's features.
y = loo_features['Labels']
X = loo_features.drop(columns={'Labels','AnimalId'})

"""Split data into training and testing for cross-validation."""
X_train, X_test, y_train, y_test = train_test_split(X, y);

"""Standardize the data since the MLP is sensitive to feature scaling."""
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
# Fit only to the training data.
scaler.fit(X_train)
# Apply the transformations to the data.
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

# Initialize the model with constant iteration max = 500.
mlp = MLPClassifier(max_iter=1000,verbose=10,tol=0.000001)
y_score = mlp.fit(X_train,y_train)
y_pred = mlp.predict(X_test)

# Define a hyperparameter space to search.
parameter_space = {
    'hidden_layer_sizes':[(100,100,100),(150,150,150)],
    'activation': ['relu','tanh'],
    'solver': ['lbfgs','sgd','adam'],
    'alpha': [0.001,0.0005],
    'learning_rate': ['constant','adaptive'],
    'batch_size': [64,128,256,512,1024]
}
# Run the search.
from sklearn.model_selection import GridSearchCV

clf = GridSearchCV(mlp, parameter_space, n_jobs=1, cv=1, verbose=10)
clf.fit(X_train, y_train)

# Print best parameters.
print('Best parameters found:\n', clf.best_params_)

# All results.
means = clf.cv_results_['mean_test_score']
stds = clf.cv_results_['std_test_score']
for mean, std, params in zip(means, stds, clf.cv_results_['params']):
    print("%0.3f (+/-%0.3f) for %r" % (mean, std * 2, params))
