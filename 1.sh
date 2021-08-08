#!/bin/bash

pwd=$PWD
DATE=$(date +'%d-%m-%Y')
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'



echo -e "$red\n ##----------------------------------------------------------------------------##$nocol\n"
echo -e "$blue\n     #### ##     ## ##     ##  #######  ########  ########    ###    ##       "
echo -e "      ##  ###   ### ###   ### ##     ## ##     ##    ##      ## ##   ##       "
echo -e "      ##  #### #### #### #### ##     ## ##     ##    ##     ##   ##  ##       "
echo -e "      ##  ## ### ## ## ### ## ##     ## ########     ##    ##     ## ##       "
echo -e "      ##  ##     ## ##     ## ##     ## ##   ##      ##    ######### ##       "
echo -e "      ##  ##     ## ##     ## ##     ## ##    ##     ##    ##     ## ##       "
echo -e "     #### ##     ## ##     ##  #######  ##     ##    ##    ##     ## ########$nocol"
echo -e "$red\n ##----------------------------------------------------------------------------##$nocol\n"




#################
#==[ Export ]===#
#################

#===[ Most Editable ]===#

export DEFCONFIG=akame_defconfig
export NKD=AkameKernel-ginkgo
export CODENAME=ginkgo
GCC_or_CLANG=2 #1 - GCC, 2 - CLANG
BUILD_KH=2 #1 - ENABLE, 2 - DISABLE
ONLY_BUILD_KH=2 #1 - DISABLE, 2 - ENABLE


#===[ Editable ]===#

export SUBARCH=$ARCH
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export JOBS="-j8"

#===[ Standart ]===#

export ANYKERNEL_DIR=AnyKernel3
export OUT_DIR=out
export ARCH=arm64
export UN=$HOME
export CONFIG=".config"

#########################
#===[ Smart Exports ]===#
#########################


if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	

#===[ Most Editable ]===#

GCC_PATH64=/usr
GCC_PATH32=/usr      	
GCC_BIN64=$GCC_PATH64/bin
GCC_BIN32=$GCC_PATH32/bin

#===[ Editable ]===#


GCC_PREF64=aarch64-linux-gnu
GCC_PREF32=arm-linux-gnueabi
GCC_PREFIX64=aarch64-linux-gnu-
GCC_PREFIX32=arm-linux-gnueabi-
GCC_LIB32=$GCC_PATH32/lib/$GCC_PREF32	
GCC_LIB64=$GCC_PATH64/lib/$GCC_PREF64	

#===[ Standart ]===#

GCC_LIBS=$GCC_LIB64:$GCC_LIB32
GCC_BINS=$GCC_BIN64:$GCC_BIN32
export LD_LIBRARY_PATH=$GCC_LIBS:$LD_LIBRARY_PATH
export PATH=$GCC_BINS:$PATH
export CROSS_COMPILE=$GCC_PREFIX64
export CROSS_COMPILE_ARM32=$GCC_PREFIX32


####---------####
#===[ Clang ]===#
####---------####
else	

#===[ Most Editable ]===#

CLANG_PATH=/usr
CLANG_BIN=$CLANG_PATH/lib/llvm-11/bin
GCC_PATH64=/usr
GCC_PATH32=/usr
GCC_BIN64=$GCC_PATH64/bin
GCC_BIN32=$GCC_PATH32/bin

#===[ Editable ]===#

GCC_PREF64=aarch64-linux-gnu          
GCC_PREF32=arm-linux-gnueabi           
GCC_PREFIX64=aarch64-linux-gnu-			
GCC_PREFIX32=arm-linux-gnueabi-
CLANG_LIB32=$CLANG_PATH/lib/llvm-11/lib
CLANG_LIB64=$CLANG_PATH/lib/llvm-11/lib64
GCC_LIB64=$GCC_PATH64/lib/$GCC_PREF64
GCC_LIB32=$GCC_PATH32/lib/$GCC_PREF32

#===[ Standart ]===#

GCC_BINS=$GCC_BIN64:$GCC_BIN32
GCC_LIBS=$GCC_LIB64:$GCC_LIB32
CLANG_LIBS=$CLANG_LIB64:$CLANG_LIB32
export LD_LIBRARY_PATH=$CLANG_LIBS:$GCC_LIBS:$LD_LIBRARY_PATH
export PATH=$CLANG_BIN:$GCC_BINS:$PATH
export CROSS_COMPILE=$GCC_PREFIX64
export CLANG_TRIPLE=$GCC_PREFIX64
export CROSS_COMPILE_ARM32=$GCC_PREFIX32
VALUES="OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
	    NM=llvm-nm \
        AR=llvm-ar \
	    AS=llvm-as"
fi


if [ "$ONLY_BUILD_KH" -eq "1" ]
then

echo -e "$yellow\n ##============================================================================##"
echo -e " ##========================= Build Kernel From Source =========================##"
echo -e " ##============================================================================##$nocol\n"

if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    make $DEFCONFIG all dtbo.img firmware_install modules_install \
	CC=gcc \
	PATH=${PATH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
	INSTALL_MOD_PATH=. \
	${JOBS}
	
	
####---------####
#===[ Clang ]===#
####---------####
else	


	sudo make $DEFCONFIG all firmware_install modules_install dtbo.img \
	CC=clang \
	PATH=${PATH} \
	CLANG_TRIPLE=${CLANG_TRIPLE} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
	${JOBS} \
    INSTALL_MOD_PATH=. \
    $VALUES
fi




if [ "$BUILD_KH" -eq "1" ]

#####################
#===[ Biuild KH ]===#
#####################
then

echo -e "$yellow\n ##============================================================================##"
echo -e " ##=========================== Build Kernel Headers ===========================##"
echo -e " ##============================================================================##$nocol\n"

sudo rm -rf /${UN}/kernel-headers/kernel-headers/

sudo rm -rf /${UN}/tmp 

rm -rf /${UN}/kernel-headers-${CODENAME}.tar.xz

mkdir /${UN}/kernel-headers/kernel-headers/

cp -r * /${UN}/kernel-headers/kernel-headers/

cd /${UN}/kernel-headers/kernel-headers/


if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then

	make $DEFCONFIG prepare modules_prepare vdso_prepare \
	CC=gcc \
	PATH=${PATH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
    	${JOBS}


####---------####
#===[ Clang ]===#
####---------####
else

   make $DEFCONFIG  prepare modules_prepare vdso_prepare \
	CC=clang \
	PATH=${PATH} \
	CLANG_TRIPLE=${CLANG_TRIPLE} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	${JOBS} \
    	$VALUES


fi

mkdir /${UN}/tmp

KN=$(find ${OUT_DIR}/lib/modules/ -name modules.*)

cp -r arch/arm* Makefile ${OUT_DIR}/Module.symvers ${KN} ${OUT_DIR}/scripts/mod/modpost ${OUT_DIR}/scripts/genksyms/genksyms  include scripts drivers/misc /${UN}/tmp 

rm -rf * 

cp -r /${UN}/tmp/* $PWD 

mv modpost scripts/mod/

mv genksyms scripts/genksyms/

rm -rf /${UN}/tmp 

mkdir arch 

cp -r arm* arch 

rm -rf arm* 

mkdir drivers 

cp -r misc drivers 

rm -rf misc

cd /${UN}/kernel-headers/kernel-headers/

cd /$UN/

sudo dpkg-deb --build kernel-headers kernel-headers-${CODENAME}.deb

ls -l kernel-headers-${CODENAME}.deb


BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue kernel-headers compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"



echo -e "$yellow\n ##============================================================================##"
echo -e " ##===================== Creating A Flashable *.zip Archive ===================##"
echo -e " ##============================================================================##$nocol\n"


cd /${UN}/${NKD}

rm -rf ${ANYKERNEL_DIR}

cp /${UN}/${ANYKERNEL_DIR} /${UN}/${NKD} -r

	
if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    KERNEL_NAME=$(make kernelrelease \
        CC=gcc
        PATH=${PATH} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        INSTALL_MOD_PATH=. \
        ${JOBS} | grep +)
	
	
####---------####
#===[ Clang ]===#
####---------####
else	

    
    KERNEL_NAME=$(make kernelrelease \
        CC=clang \
        PATH=${PATH} \
        CLANG_TRIPLE=${CLANG_TRIPLE} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} \
        INSTALL_MOD_PATH=. \
        $VALUES | grep +)
fi


        


mkdir -p ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
mkdir -p ${ANYKERNEL_DIR}/modules/system/etc/firmware


cd /${UN}/${NKD}


#===[ COPYNG ]===#


cd ${OUT_DIR} && cp $(find -name *.ko) --parents ../${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
cd firmware
cp $(find -name *.bin) -r --parents ${UN}/${NKD}/${ANYKERNEL_DIR}/modules/system/etc/firmware
cp $(find -name *.fw) -r --parents ${UN}/${NKD}/${ANYKERNEL_DIR}/modules/system/etc/firmware
cd ..
cp modules.* ../${ANYKERNEL_DIR}/modules/system/lib/modules/ 
cd .. 
cp $(find -name dtbo.img) ${ANYKERNEL_DIR}/


#===[ EDITABLE ]===#

cp $(find -name Image.gz-dtb) ${ANYKERNEL_DIR}/
#cp $(find -name Image.gz) ${ANYKERNEL_DIR}
#cp $(find -name dtb) ${ANYKERNEL_DIR}


#===[ ZIPPING ]===#

rm -rf ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel/lib/

cd ${ANYKERNEL_DIR} && zip -r -9 AkameKernel-${CODENAME}-$(date +%d-%m-%y).zip * -x .git README.md *placeholder

######################
#===[ TIME BUILD ]===#
######################

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Kernel compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"





#################
#===[Skip KH]===#
#################
else

echo -e "$yellow\n ##============================================================================##"
echo -e " ##===================== Creating A Flashable *.zip Archive ===================##"
echo -e " ##============================================================================##$nocol\n"


cd /${UN}/${NKD}

rm -rf ${ANYKERNEL_DIR}

cp /${UN}/${ANYKERNEL_DIR} /${UN}/${NKD} -r

	
if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    KERNEL_NAME=$(make kernelrelease \
        CC=gcc
        PATH=${PATH} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} | grep +)
	
	
####---------####
#===[ Clang ]===#
####---------####
else	

    
    KERNEL_NAME=$(make kernelrelease \
        CC=clang \
        PATH=${PATH} \
        CLANG_TRIPLE=${CLANG_TRIPLE} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} \
        $VALUES | grep +)
fi


        


mkdir -p ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
mkdir -p ${ANYKERNEL_DIR}/modules/system/etc/firmware


cd /${UN}/${NKD}


#===[ COPYNG ]===#


cd ${OUT_DIR} && cp $(find -name *.ko) --parents ../${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
cd firmware
cp $(find -name *.bin) -r --parents ${UN}/${NKD}/${ANYKERNEL_DIR}/modules/system/etc/firmware
cp $(find -name *.fw) -r --parents ${UN}/${NKD}/${ANYKERNEL_DIR}/modules/system/etc/firmware
cd ..
cp modules.* ../${ANYKERNEL_DIR}/modules/system/lib/modules/
cd ..

cp $(find -name dtbo.img) ${ANYKERNEL_DIR}/


#===[ EDITABLE ]===#

cp $(find -name Image.gz-dtb) ${ANYKERNEL_DIR}/
#cp $(find -name Image.gz) ${ANYKERNEL_DIR}/
#cp $(find -name dtb) ${ANYKERNEL_DIR}/


#===[ ZIPPING ]===#

rm -rf ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel/lib/

cd ${ANYKERNEL_DIR} && zip -r -9 AkameKernel-${CODENAME}-$(date +%d-%m-%y).zip * -x .git README.md *placeholder

######################
#===[ TIME BUILD ]===#
######################

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Kernel compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"

fi


#####################
#===[ END BUILD ]===#
#####################




#####################################
#===[ ONLY BUILD KERNEL HEADERS ]===#
#####################################



else


echo -e "$yellow\n ##============================================================================##"
echo -e " ##=========================== Build Kernel Headers ===========================##"
echo -e " ##============================================================================##$nocol\n"

sudo rm -rf /${UN}/kernel-headers/kernel-headers/

sudo rm -rf /${UN}/tmp 

rm -rf /${UN}/kernel-headers-${CODENAME}.tar.xz

mkdir /${UN}/kernel-headers/kernel-headers/

cp -r * /${UN}/kernel-headers/kernel-headers/

cd /${UN}/kernel-headers/kernel-headers/


if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then

	make $DEFCONFIG prepare modules_prepare vdso_prepare \
	CC=gcc \
	PATH=${PATH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
    	${JOBS}


####---------####
#===[ Clang ]===#
####---------####
else

   make $DEFCONFIG  prepare modules_prepare vdso_prepare \
	CC=clang \
	PATH=${PATH} \
	CLANG_TRIPLE=${CLANG_TRIPLE} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	${JOBS} \
    	$VALUES


fi

mkdir /${UN}/tmp

KN=$(find ${OUT_DIR}/lib/modules/ -name modules.*)

cp -r arch/arm* Makefile ${OUT_DIR}/Module.symvers ${KN} ${OUT_DIR}/scripts/mod/modpost ${OUT_DIR}/scripts/genksyms/genksyms  include scripts drivers/misc /${UN}/tmp 

rm -rf * 

cp -r /${UN}/tmp/* $PWD 

mv modpost scripts/mod/

mv genksyms scripts/genksyms/

rm -rf /${UN}/tmp 

mkdir arch 

cp -r arm* arch 

rm -rf arm* 

mkdir drivers 

cp -r misc drivers 

rm -rf misc

cd /${UN}/kernel-headers/kernel-headers/

cd /$UN/

sudo dpkg-deb --build kernel-headers kernel-headers-${CODENAME}.deb

ls -l kernel-headers-${CODENAME}.deb


BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue kernel-headers compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"


fi

fi





