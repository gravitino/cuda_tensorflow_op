#!/usr/bin/env python

import tensorflow as tf
module = tf.load_op_library('./cuda_op_kernel.so')

# make sure you have tensorflow with GPU support
with tf.Session('') as sess:
        ret = module.add_one([[1, 2], [3, 4]]).eval()
print(ret)
exit(0)
