CUDA_HOME ?= $(shell echo $$(dirname $$(dirname $$(find -P / -name "nvcc" -print -quit 2>/dev/null))))
NVCC=$(CUDA_HOME)/bin/nvcc
NVCCFLAGS= -arch=sm_52 -gencode arch=compute_30,code=compute_30 \
                       -gencode arch=compute_35,code=compute_35 \
                       -gencode arch=compute_52,code=compute_52 \
                       -gencode arch=compute_61,code=compute_61 \
           --expt-relaxed-constexpr
CXX=g++
CXXFLAGS= -std=c++11 -O2 -D_GLIBCXX_USE_CXX11_ABI=0

TF_INC ?= $(shell python -c 'import tensorflow as tf; print(tf.sysconfig.get_include())') 

all: info cuda_op_kernel.so

info:
	@echo -e '==== INFO =========================================='
	@echo -e '  CUDA_HOME=$(CUDA_HOME)                            '
	@echo -e '  TF_INC=$(TF_INC)                                  '
	@echo -e '===================================================='

cuda_op_kernel.cu.o: cuda_op_kernel.cu.cc
	$(NVCC) $(NVCCFLAGS) cuda_op_kernel.cu.cc  -c -o cuda_op_kernel.cu.o -I $(TF_INC) -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $(CXXFLAGS)

cuda_op_kernel.cc.o: cuda_op_kernel.cc
	$(CXX) $(CXXFLAGS) cuda_op_kernel.cc -c -o cuda_op_kernel.cc.o -I $(TF_INC) -fPIC -Wall 

cuda_op_kernel.so: cuda_op_kernel.cu.o cuda_op_kernel.cc.o
	$(CXX) $(CXXFLAGS) -shared -o cuda_op_kernel.so cuda_op_kernel.cc.o cuda_op_kernel.cu.o -lcudart -L $(CUDA_HOME)/lib64

clean:
	rm -f *.o
	rm -f *.so
