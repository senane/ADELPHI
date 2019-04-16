
# coding: utf-8

# In[56]:


from __future__ import absolute_import, division, print_function
from matplotlib.font_manager import _rebuild; _rebuild()
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io as spio
import tensorflow as tf
from keras.callbacks import EarlyStopping, TensorBoard
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras import optimizers
from keras.wrappers.scikit_learn import KerasClassifier
from keras.utils import np_utils, to_categorical
from sklearn.preprocessing import LabelEncoder, StandardScaler, MultiLabelBinarizer
from sklearn.model_selection import train_test_split
import csv
import logging
import random
import re
import string
import sys
tf.reset_default_graph()
# Initialize random number generator for reproducibility.
seed = 7
np.random.seed(seed)
# sys.stdout = open("keras_pooled_mlp_log.txt", "w")

# Set up logging for pipeline mechanics.
# logging.basicConfig(filename='pooled_mlp_keras.log', 
#                     filemode='w', 
#                     format='%(name)s - %(levelname)s - %(message)s',
#                     level=logging.INFO)
# logging.info("Loading data...")

# Load in dataset.
data = spio.loadmat("features_10s_2019-01-30.mat");
features = data['features'];
labels = data['labels_features'];
animal_id_features = data['animal_id_features'].transpose();
animal_names = data['animal_names'].transpose();
feat_names = data['feat_names'];
col_names = pd.DataFrame(feat_names)
logging.info("Data loaded successfully!")


# In[57]:


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

# Create a dataframe of features with columns named & rows labeled.
feat_data = pd.DataFrame(data=features,columns=cols)
feat_data.insert(0,'AnimalId',animal_id_features)
feat_data.insert(0,'Labels',labels.transpose())

# Separate features from targets. (Drop AnimalID as confounding.)
y = feat_data['Labels']
X = feat_data.drop(columns={'Labels','AnimalId'})

print(X.iloc[0].shape)

# Encode class values as integers.
encoder = LabelEncoder()
encoder.fit(y)
encoded_y = encoder.transform(y)


# Split data into training (80%) and testing (20%).
X_train, X_test, y_train, y_test = train_test_split(X, encoded_y, test_size=0.2)
# Encodes into 3 categorical features
# y_train_cat = np_utils.to_categorical(y_train) 
# y_test_cat = np_utils.to_categorical(y_test)

# Train the scaler, which standarizes features (mean=0 & unit variance)
scaler = StandardScaler()
scaler.fit(X_train)

# Apply the transformations to the data.
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)


# In[ ]:


# Set up TensorBoard callbacks
tb_callback = TensorBoard(log_dir='./logs/', 
                                         histogram_freq=0,
                                         write_graph=True, 
                                         write_images=True)

# Set up Early Stopping for if loss begins to increase
early_callback = EarlyStopping(monitor='val_loss',
                              min_delta=0,
                              patience=2,
                              verbose=0, mode='auto')

logging.info("Initializing Model: Keras Sequential NN\n")
# print("X_train shape: {}\n".format(X_train.shape))
# print("y_train shape: {}\n".format(y_train.shape))
# print("y_train_cat shape: {}\n".format(y_train_cat.shape))
# print("y_train first row: {}\n".format(y_train[0]))

# Creates a model with architecture 141 inputs -> [32 hidden nodes] -> 3 outputs
# Create model.
model = Sequential()
model.add(Dense(141, 
                activation='relu', 
                input_dim=X_train.shape[1]))
# Add dropout
model.add(Dropout(0.5))
#adding the second hidden layer
#     model.add(Dense(50, 
#                    kernel_initializer ='uniform',
#                    activation = 'relu'))
# Adding output layer
model.add(Dense(3,kernel_initializer="uniform", 
                    activation="softmax"))
# Compile model 
model.compile(loss='sparse_categorical_crossentropy', 
                  optimizer='adam', 
                  metrics=['accuracy'])
# Fit the model
history = model.fit(X_train, y_train,
                    epochs=150,
                      batch_size=512,
                      validation_split=0.2,
                      shuffle=True,
                   callbacks=[tb_callback, early_callback])

# Score the model
score = model.evaluate(X_test, y_test, batch_size=512)

