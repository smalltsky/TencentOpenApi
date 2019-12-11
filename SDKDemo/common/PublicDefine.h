/*
 *  PublicDefine.h
 *
 *  Created by cocozzhang on 19-07-24.
 */

#define QQ_OPEN_SDK_LITE 1 //0对内包，1对外包

#pragma mark - 功能开关

//添加好友
#define OPEN_API_ADD_FRIEND (!(QQ_OPEN_SDK_LITE) && 1)

#pragma mark 群相关
#define OPEN_API_GROUP (!(QQ_OPEN_SDK_LITE) && 1)
//一键加群
#define OPEN_API_JOIN_GROUP_OLD (!(QQ_OPEN_SDK_LITE) && OPEN_API_GROUP && 1 )
//游戏绑定公会群
#define OPNE_API_GAME_BIND_GROUP (!(QQ_OPEN_SDK_LITE) && OPEN_API_GROUP && 1)
//新-一键加群
#define OPEN_API_JOIN_GROUP (!(QQ_OPEN_SDK_LITE) && OPEN_API_GROUP && 1)
//新-绑定群功能
#define OPNE_API_BIND_GROUP (!(QQ_OPEN_SDK_LITE) && OPEN_API_GROUP && 1)
//新-解除绑定群
#define OPEN_API_UNBIND_GROUP (!(QQ_OPEN_SDK_LITE) && OPNE_API_BIND_GROUP && OPEN_API_GROUP && 1)
