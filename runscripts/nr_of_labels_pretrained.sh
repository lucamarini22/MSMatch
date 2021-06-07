#!/bin/bash
export CUDA_VISIBLE_DEVICES=2
DEVICE=0
FIXMATCH_FOLDER="$HOME/project/SSLRS/"
SAVE_LOCATION="/scratch/fixmatch_results/runs_new_paper_version/" #Where tensorboard output will be written
SAVE_NAME="nr_of_labels_pretrained" 
DATASET=aid  #Dataset to use: Options are eurosat_ms, eurosat_rgb, aid, ucm
NET=efficientnet-b2 #Options are wideResNet,efficientnet-b0, efficientnet-b1, efficientnet-b2, efficientnet-b3, efficientnet-b4, efficientnet-b5,...  
UNLABELED_RATIO=4
BATCH_SIZE=16
N_EPOCH=500                    #Set NUM_TRAIN_ITER = N_EPOCH * NUM_EVAL_ITER * 32 / BATCH_SIZE
NUM_EVAL_ITER=1000            #Number of iterations 
NUM_TRAIN_ITER=$(($N_EPOCH * $NUM_EVAL_ITER * 32/ BATCH_SIZE))
SEED=0
WEIGHT_DECAY=0.00075
LR=0.03
PRETRAINED_COMMAND="--pretrained"
ULB_LOSS_RATIO=0.0
RED='\033[0;31m'
BLACK='\033[0m'
URL_DIST="tcp://127.0.0.1:10007" #change port to avoid conflicts to allow multiple multi-gpu runs
#create save location
mkdir -p $SAVE_LOCATION

#switch to fixmatch folder for execution
cd $FIXMATCH_FOLDER
if [[ ${#CUDA_VISIBLE_DEVICES} > 1 ]]
then
	echo -e "${RED} Multi-GPU mode ${BLACK}"
	for NUM_LABELS in 100 500 1000 2000 3000; do  #Note: they are the total number of labels, not per class.
		#Remove "echo" to launch the script.
		echo python train.py --weight_decay $WEIGHT_DECAY --world-size 1 --rank 0 --multiprocessing-distributed --dist-url $URL_DIST --lr $LR --batch_size $BATCH_SIZE --num_train_iter $NUM_TRAIN_ITER --num_eval_iter $NUM_EVAL_ITER --num_labels $NUM_LABELS --save_name $SAVE_NAME --save_dir $SAVE_LOCATION --dataset $DATASET --net $NET --seed $SEED --uratio $UNLABELED_RATIO $PRETRAINED_COMMAND
		wait
	done
else
	for NUM_LABELS in 50 100 500 1000 2000 3000; do #Note: they are the total number of labels, not per class.
		#Remove "echo" to launch the script.
		echo python train.py --weight_decay $WEIGHT_DECAY --rank 0 --gpu $DEVICE --lr $LR --batch_size $BATCH_SIZE --num_train_iter $NUM_TRAIN_ITER --num_eval_iter $NUM_EVAL_ITER --num_labels $NUM_LABELS --save_name $SAVE_NAME --save_dir $SAVE_LOCATION --dataset $DATASET --net $NET --seed $SEED --uratio $UNLABELED_RATIO $PRETRAINED_COMMAND
		wait
	done
fi