#设置变量
# TARGET="sdkDemo"
CONFIGURATION=Release
PROJECT="$TARGET"

#local run example:XCODE_PATH=xcodebuild
BUILD_FOLDER=../../build/$CONFIGURATION-iphoneos/


cd release/sdkDemo
__CURDIR__=`pwd`


##这里执行sed命令删除工程对libmakeFramework.a静态库的依赖
sed -i "" "/libmakeFramework\.a/d" "sdkDemo.xcodeproj/project.pbxproj"
##

##这里视情况决定编译QQApiDemo
if [ "$BUILD_QQAPIDEMO" = "" ]; then
    BUILD_MACRO_SWITCH=0
else
    BUILD_MACRO_SWITCH=1
fi

echo "" >> sdkDemo/sdkDemo-Prefix.pch
echo "#define BUILD_QQAPIDEMO $BUILD_MACRO_SWITCH" >> sdkDemo/sdkDemo-Prefix.pch
echo "" >> sdkDemo/sdkDemo-Prefix.pch
##


##这里视情况决定编译WTLOGIN demo
if [ "$BUILD_WTLOGIN_DEMO" = "" ]; then
    BUILD_WTLOGIN_DEMO_SWITCH=0
else
    BUILD_WTLOGIN_DEMO_SWITCH=1
fi

echo "" >> sdkDemo/sdkDemo-Prefix.pch
echo "#define ENABLE_WTLOGIN_SDK_DEMO $BUILD_WTLOGIN_DEMO_SWITCH" >> sdkDemo/sdkDemo-Prefix.pch
echo "" >> sdkDemo/sdkDemo-Prefix.pch
##


##这里执行sed命令替换工程文件中的签名为rdm中已有的签名
#sed -i "" "s/\(CODE_SIGN_IDENTITY = \).*$/\1\"iPhone Developer: Fengfu Liu (M2T4NWYNTB)\";/g" "sdkDemo.xcodeproj/project.pbxproj"
#sed -i "" "s/\(\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" = \).*$/\1\"iPhone Developer: Fengfu Liu (M2T4NWYNTB)\";/g" "sdkDemo.xcodeproj/project.pbxproj"
##

##这里执行sed命令替换工程文件中的证书为rdm中已有的证书
sed -i "" "s/\(PROVISIONING_PROFILE = \).*$/\1\"1a61ba33-a035-40d6-89b0-3695d0444793\";/g" "sdkDemo.xcodeproj/project.pbxproj"
sed -i "" "s/\(\"PROVISIONING_PROFILE\[sdk=iphoneos\*\]\" = \).*$/\1\"1a61ba33-a035-40d6-89b0-3695d0444793\";/g" "sdkDemo.xcodeproj/project.pbxproj"
##

##自定义appid、qq_appid以及app显示名称
RDM_XCCONFIG_PATH="sdkDemo/Configuration/RDM.xcconfig"
echo "" >> "$RDM_XCCONFIG_PATH"
if [ "$TENCENT_APPID" != "" ]; then
    echo "TENCENT_APPID = $TENCENT_APPID" >> "$RDM_XCCONFIG_PATH"
    PROJECT="$TENCENT_APPID"
fi

if [ "$QQ_APPID" != "" ]; then
    echo "QQ_APPID = $QQ_APPID" >> "$RDM_XCCONFIG_PATH"
fi

if [ "$TX_DISPLAY_NAME" != "" ]; then
    echo "TX_DISPLAY_NAME = $TX_DISPLAY_NAME" >> "$RDM_XCCONFIG_PATH"
fi

#执行清理操作,这里需要替换对应的target名字和config、以及对应的SDK版本;
#如替换后的语句为:xcodebuild -target dailybuildipa -configuration release clean -sdk iphoneos4.3
$XCODE_PATH -target "$TARGET" -configuration $CONFIGURATION clean -sdk $SDK CONFIGURATION_BUILD_DIR=$BUILD_FOLDER
if [ -e  $BUILD_FOLDER*.ipa ] ;then
cd $BUILD_FOLDER;
rm -r *;
cd __CURDIR__;
fi

#与clean操作类似，也需要替换对应的target名字和config、以及对应的SDK版本;
$XCODE_PATH -target "$TARGET" -configuration $CONFIGURATION CONFIGURATION_BUILD_DIR=$BUILD_FOLDER
if ! [ $? = 0 ] ;then
exit 1
fi

mkdir "$BUILD_FOLDER"Payload
cp -r $BUILD_FOLDER"$PROJECT".app "$BUILD_FOLDER"Payload
cd $BUILD_FOLDER
zip -r "$PROJECT".ipa Payload iTunesArtword
cd __CURDIR__

#如果项目是在根目录的子目录中，则需要cp xxx ../result/$BaseLine.ipa 
cp $BUILD_FOLDER*.ipa  ../../result/"$PROJECT"_svn"$SVN_REVISION"_"$BaseLine".ipa

cd ../..
