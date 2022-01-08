--
require 'TFFramework.SDK.android.SDKConfig'
-- local json = require('sdk.json')
-- require('sdk.base.utf8')
require('TFFramework.SDK.android.urlCodec')
--

local insHttp = TFClientNetHttp:GetInstance() 
local NULL = "null"

local SDKAndroid = {}
--user 
SDKAndroid.APP_ID = "appId"
SDKAndroid.USER_NAME = "userName"
SDKAndroid.USER_ID = "userId"
SDKAndroid.PLATFORM_TOKEN = "platformToken"
SDKAndroid.TOKEN = "token"
SDKAndroid.RESULT_MSG ="resultMsg"
SDKAndroid.PLATFORM = "platform"
SDKAndroid.IS_REQUEST_LOGININFO ="isRequestLoginInfo"
SDKAndroid.SDK_VERSION = "sdkVersion"

--pay
SDKAndroid.PAYRESULT_MSG = "resultMsg";
SDKAndroid.PAY_CODE = "action"

SDKAndroid.TOTAL_PRICES ="totalPrices";
SDKAndroid.ORDER_NO ="orderNo";
SDKAndroid.ORDER_TITLE ="orderTitle";
SDKAndroid.PAY_DESCRIPTION ="payDescription";
SDKAndroid.PRODUCT_ID = "productId";
SDKAndroid.PRODUCT_NAME ="productName";
SDKAndroid.PRODUCT_COUNT ="productCount";
SDKAndroid.USER_BALANCE ="userBalance";
--role
SDKAndroid.ROLE_ID ="roleId";
SDKAndroid.ROLE_NAME ="roleName";
SDKAndroid.SERVER_ID ="serverId";
SDKAndroid.SERVER_NAME ="serverName";
SDKAndroid.ROLE_LEVEL ="roleLevel";
SDKAndroid.VIP_LEVEL ="vipLevel";
SDKAndroid.PARTY_NAME ="partyName";
SDKAndroid.GOOD_REGISTID = "goodRegistId";

--- produceList const
SDKAndroid.PRODUCT_LIST="productList";

-- share contect
SDKAndroid.SHARE_NAME ="name";
SDKAndroid.SHARE_CAPTION ="caption";
SDKAndroid.SHARE_DESCRIPTION ="description";
SDKAndroid.SHARE_URL ="shareUrl";
SDKAndroid.SHARE_PICTURE_URL ="pictureUrl";
SDKAndroid.SHARE_STYLE ="shareSytle";
SDKAndroid.SHARE_STYLE_API = 0;
SDKAndroid.SHARE_STYLE_WEB_DIALOG = 1;

-- ----callback code
--init
SDKAndroid.ACTION_RET_INIT_SUCCEED = 0;
SDKAndroid.ACTION_RET_INIT_FAILED = 1;
-- login
SDKAndroid.ACTION_RET_LOGIN_SUCCEED = 2;
SDKAndroid.ACTION_RET_LOGIN_FAILED = 3;
-- logout 
SDKAndroid.ACTION_RET_LOGOUT_SUCCEED = 4;
SDKAndroid.ACTION_RET_LOGOUT_FAILED = 5;
-- enter platform 
SDKAndroid.ACTION_RET_ENTERPLATFORM_SUCCEED = 6;
SDKAndroid.ACTION_RET_ENTERPLATFORM_FAILED = 7;
-- switch account 
SDKAndroid.ACTION_RET_SWITCHACCOUNT_SUCCEED= 8;
SDKAndroid.ACTION_RET_SWITCHACCOUNT_FAILED= 9;

--- get product list 
SDKAndroid.ACTION_RET_GET_PRODUCT_LIST_SUCCESS = 10;
SDKAndroid.ACTION_RET_GET_PRODUCT_LIST_FAILED = 11;

---share (facebook)
SDKAndroid.ACTION_RET_SHARE_SUCCESS = 12;
SDKAndroid.ACTION_RET_SHARE_FAILED = 13;


SDKAndroid.ACTION_RET_REQUESTINFO_SUCCEED= 1000
SDKAndroid.ACTION_RET_REQUESTINFO_FAILED= 1001

-- call java method
SDKAndroid.ACTION_CALL_JAVA_METHOD = "action"; -- 调用java方法的 action字段

SDKAndroid.ACTION_RET_REQUEST_GET_PRODUCT_LIST_METHOD = 100;    -- 调用获取商品列表方法的action
SDKAndroid.ACTION_RET_REQUEST_GET_SDK_VERSION = 101;    -- 调用获取sdk 版本方法的action
SDKAndroid.ACTION_RET_ON_EVENT_ACTION_ID = 102;    -- onEventActionId 的 action 
SDKAndroid.ACTION_RET_REQUEST_SHARE_METHOD = 103;    -- 调用分享方法的action

-- pay 
SDKAndroid.PAYRESULT_SUCCESS = 0;
SDKAndroid.PAYRESULT_FAIL    = 1;
SDKAndroid.PAYRESULT_CANCEL  = 2;
SDKAndroid.PAYRESULT_TIMEOUT = 3;

--
SDKAndroid.CALLBACK_RESULT = "result"
SDKAndroid.CALLBACK_MSG = "msg"
SDKAndroid.CALLBACK_GAMESERVER = "gameServers"
SDKAndroid.CALLBACK_UIN = "uin"
SDKAndroid.CALLBACK_UNAME = "uname"

--callbacktable
SDKAndroid.sdkcallbacks = {
      init_callback = nil,
      login_callback = nil,
      logout_callback = nil,
      enterplatform_callback = nil,
      switchaccount_callback = nil,
      pay_callback = nil,
      get_product_list_callback = nil,
      get_sdk_version_callback = nil,
      share_callback = nil,
}

function  SDKAndroid.requestServerList()
      print("===============requestServerList===================")
      --SDK_SERVER_YRL 动态写入
      local url = SDK_SERVER_URL
      print("url", url)
      local request = {
          uin = SDKAndroid[SDKAndroid.USER_ID] or "",
          platform = SDKAndroid[SDKAndroid.PLATFORM] or "",
          token = SDKAndroid[SDKAndroid.TOKEN] or "",
      }
      print("requestServerList param", json.encode(request))
      insHttp:httpRequest(TFHTTP_TYPE_POST, url,json.encode(request))
      insHttp:addMERecvListener(function (type, ret, data)
          print("type, ret", type, ret)
          if not data then return end
          local decode_data = string.url_decode(data)
          -- local decode_data   = TFStringUtils:urlDecodeUtf8(data)
          print("decode_data", decode_data)
          local server_data = json.decode(decode_data)
          print("json server_data", server_data)
          local response = {
              [SDKAndroid.CALLBACK_RESULT] = server_data[SDKAndroid.CALLBACK_RESULT],
              [SDKAndroid.CALLBACK_MSG] = server_data[SDKAndroid.CALLBACK_MSG],
              [SDKAndroid.CALLBACK_GAMESERVER] = server_data[SDKAndroid.CALLBACK_GAMESERVER],
          }
          SDKAndroid.sdkcallbacks["login_callback"](response)
      end)
end

function SDKAndroid.requestUserInfo()
      local url = SDK_LOGIN_URL
      print("url", url)
      local param = {
      uin = SDKAndroid[SDKAndroid.USER_ID] or "",
      uname = SDKAndroid[SDKAndroid.USER_NAME] or "",
      platform = SDKAndroid[SDKAndroid.PLATFORM] or "",
      appID = SDKAndroid[SDKAndroid.APP_ID] or "",
      platformToken = SDKAndroid[SDKAndroid.PLATFORM_TOKEN] or "",
      deviceID = "",
      iosDeviceToken = "",
  }
  print("httpRequest login info", url, json.encode(param))
      insHttp:httpRequest(TFHTTP_TYPE_POST, url,json.encode(param))
      insHttp:addMERecvListener(function (type, ret, data)
          print("type, ret", type, ret,data)
          if not data then return end
          -- local decode_data   = TFStringUtils:urlDecodeUtf8(data)
          local decode_data = string.url_decode(data)
          local info_table = json.decode(decode_data)
          print("json info_table", info_table)
          SDKAndroid[SDKAndroid.TOKEN] =  info_table[SDKAndroid.TOKEN]
          SDKAndroid[SDKAndroid.USER_NAME] = info_table[SDKAndroid.CALLBACK_UNAME]
          SDKAndroid[SDKAndroid.USER_ID] = info_table[SDKAndroid.CALLBACK_UIN]
          SDKAndroid[SDKAndroid.PLATFORM_TOKEN] = info_table[SDKAndroid.PLATFORM_TOKEN]
          if info_table[SDKAndroid.CALLBACK_RESULT] == 0 then
            SDKAndroid.requestServerList()
          else
            local response = {
              [SDKAndroid.CALLBACK_RESULT] = info_table[SDKAndroid.CALLBACK_RESULT],
              [SDKAndroid.CALLBACK_MSG] = info_table[SDKAndroid.CALLBACK_MSG],
              [SDKAndroid.CALLBACK_GAMESERVER] = "",
            }
            SDKAndroid.sdkcallbacks["login_callback"](response)
          end
        end)
end


local function formatString(data)
      if data == nil or data == NULL then 
        return ""
      else
        return data
      end
end

function SDKAndroid.usersdk_callback(plugin, code, msg )
      print("*******protocol", plugin)
      print("*******code", code)
      print("*******msg", msg)
      local  resultTab = json.decode(msg);
      print("******* resultTab" ,resultTab);

      -- init succeed callback
      if code == SDKAndroid.ACTION_RET_INIT_SUCCEED then
          print("init success")
          if resultTab[SDKAndroid.PLATFORM] then
              SDKAndroid[SDKAndroid.PLATFORM]  = formatString(resultTab[SDKAndroid.PLATFORM]);
          end
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = 0,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["init_callback"](response)
      -- init failed callback
      elseif  code == SDKAndroid.ACTION_RET_INIT_FAILED  then
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["init_callback"](response)

      elseif code == SDKAndroid.ACTION_RET_LOGIN_SUCCEED  then
          print("login success")
          local msgtable = json.decode(msg)
          print("SDKAndroid msgtable", msgtable) 
          if msgtable[SDKAndroid.APP_ID] == nil or msgtable[SDKAndroid.APP_ID] == NULL then
              SDKAndroid[SDKAndroid.APP_ID] = "0"
          else
              SDKAndroid[SDKAndroid.APP_ID] = msgtable[SDKAndroid.APP_ID]
          end 
          SDKAndroid[SDKAndroid.USER_NAME] = formatString(msgtable[SDKAndroid.USER_NAME])
          SDKAndroid[SDKAndroid.USER_ID] = formatString(msgtable[SDKAndroid.USER_ID])
          SDKAndroid[SDKAndroid.TOKEN] =  formatString(msgtable[SDKAndroid.TOKEN])
          SDKAndroid[SDKAndroid.PLATFORM] =  formatString(msgtable[SDKAndroid.PLATFORM])
          SDKAndroid[SDKAndroid.PLATFORM_TOKEN] =formatString(msgtable[SDKAndroid.PLATFORM_TOKEN])
          if not msgtable[SDKAndroid.IS_REQUEST_LOGININFO] then
              SDKAndroid.requestUserInfo()
          else
              SDKAndroid.requestServerList()
          end  

      elseif code == SDKAndroid.ACTION_RET_LOGIN_FAILED then
          print("login failed")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG]),
            [SDKAndroid.CALLBACK_GAMESERVER] = ""
          }
          SDKAndroid.sdkcallbacks["login_callback"](response)

      -- logout  succeed callback
      elseif code == SDKAndroid.ACTION_RET_LOGOUT_SUCCEED  then
          print("logOut success")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = 0,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG]),
          }
          SDKAndroid.sdkcallbacks["logout_callback"](response)

        -- logout failed callback 
      elseif code == SDKAndroid.ACTION_RET_LOGOUT_FAILED then
          print("logOut failed")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["logout_callback"](response)

      -- enter platform  succeed callback
      elseif code == SDKAndroid.ACTION_RET_ENTERPLATFORM_SUCCEED  then
          print("platform success")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = 0,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["enterplatform_callback"](response)

        --enter platform  failed callback
      elseif code == SDKAndroid.ACTION_RET_ENTERPLATFORM_FAILED  then
          print("platform failed")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["enterplatform_callback"](response)

      -- switch account succeed callback
      elseif code == SDKAndroid.ACTION_RET_SWITCHACCOUNT_SUCCEED then
          print("switch success")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = 0,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["switchaccount_callback"](response)

        -- switch account failed callback
      elseif code == SDKAndroid.ACTION_RET_SWITCHACCOUNT_FAILED then
          print("switch failed")
          local response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          }
          SDKAndroid.sdkcallbacks["switchaccount_callback"](response)

        --  get product list  succeed callback
      elseif code == SDKAndroid.ACTION_RET_GET_PRODUCT_LIST_SUCCESS then
          local msgtable = json.decode(msg)
          print("SDKAndroid msgtable", msgtable)
          print(" get product list success callback");
          local  response = {
            [SDKAndroid.CALLBACK_RESULT] = 0,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG]),
            [SDKAndroid.PRODUCT_LIST] = formatString(resultTab[SDKAndroid.PRODUCT_LIST])
          };
          SDKAndroid.sdkcallbacks["get_product_list_callback"](response)

      --  get product list  failed callback
      elseif code == SDKAndroid.ACTION_RET_GET_PRODUCT_LIST_FAILED then
          print(" get product list fail callback");
          local  response = {
            [SDKAndroid.CALLBACK_RESULT] = code,
            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          };
          SDKAndroid.sdkcallbacks["get_product_list_callback"](response)

      -- get sdk version callback
      elseif code == SDKAndroid.ACTION_RET_REQUEST_GET_SDK_VERSION then
          if resultTab[SDKAndroid.SDK_VERSION] == nil or resultTab[SDKAndroid.SDK_VERSION] == NULL then
              SDKAndroid[SDKAndroid.SDK_VERSION] = "0";
          else
              SDKAndroid[SDKAndroid.SDK_VERSION]= resultTab[SDKAndroid.SDK_VERSION];
          end 
          SDKAndroid.sdkcallbacks["get_sdk_version_callback"](SDKAndroid[SDKAndroid.SDK_VERSION]);

	-- share callback
	  elseif code == SDKAndroid.ACTION_RET_SHARE_SUCCESS then
	    print(" share success callback");
	    local  response = {
	            [SDKAndroid.CALLBACK_RESULT] = 0,
	            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          };
	    SDKAndroid.sdkcallbacks["share_callback"](response);
	  elseif code == SDKAndroid.ACTION_RET_SHARE_FAILED then
	    print(" share fail callback");
	    local  response = {
	            [SDKAndroid.CALLBACK_RESULT] = code,
	            [SDKAndroid.CALLBACK_MSG] = formatString(resultTab[SDKAndroid.RESULT_MSG])
          };
	    SDKAndroid.sdkcallbacks["share_callback"](response);


	  end 

end

function  SDKAndroid.iapsdk_callback(ret, info, productinfo)
      print("SDKAndroid ret",ret)
      print("SDKAndroid info",info)
      print("SDKAndroid productinfo",productinfo)

      local response = json.decode(info)
      print("SDKAndroid ipa result", response)

      if ret == SDKAndroid.PAYRESULT_SUCCESS then
          print("pay success")
      elseif ret == SDKAndroid.PAYRESULT_FAIL then
          print("pay fail")
      elseif ret == SDKAndroid.PAYRESULT_CANCEL then
          print("cancel")
      elseif ret == SDKAndroid.PAYRESULT_TIMEOUT then
          print("time out ")
      end
      response[SDKAndroid.PAY_CODE] = ret,
      SDKAndroid.sdkcallbacks["pay_callback"](response)
end

function SDKAndroid:init(callback)
      print("===============init===================") 
      SDKAndroid.sdkcallbacks.init_callback = callback
      print(" SDKAndroid.sdkcallbacks",  SDKAndroid.sdkcallbacks)
      print(" SDKAndroid.sdkcallbacks init",  SDKAndroid.sdkcallbacks.init)
      TFSdkManager:getInstance():initPlugin(sdkuser, TFSdkManager.ePluginUser)  
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:configDeveloperInfo()
      user_plugin:setActionListener(SDKAndroid.usersdk_callback)

      TFSdkManager:getInstance():initPlugin(sdkiap, TFSdkManager.ePluginIAP)  
      local iap_plugin = TFSdkManager:getInstance():getIAPPlugin()
      if not iap_plugin then
          print "iap_plugin is nil"
          return
      end 
      iap_plugin:configDeveloperInfo()
      iap_plugin:setResultListener(SDKAndroid.iapsdk_callback)
end

function SDKAndroid:login(callback)
      print("===============logIn===================")
      SDKAndroid.sdkcallbacks.login_callback = callback
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:login()
end


function SDKAndroid:setLogoutCallback(callback)
      print("===============setLogoutCallback===================")
      SDKAndroid.sdkcallbacks.logout_callback = callback  
end
function SDKAndroid:setLeavePlatformCallback(callback)
      print("===============setLeavePlatformCallback=================== This's callback is invalid")  
end

function SDKAndroid:logout(callback)
      print("===============logOut===================")
      SDKAndroid.sdkcallbacks.logout_callback = callback
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:logout()
end

function SDKAndroid:switchAccount(callback)
      print("===============switchAccount===================")
      SDKAndroid.sdkcallbacks.switchaccount_callback = callback
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:switchAccount()
end

function SDKAndroid:enterPlatform(callback)
      print("===============enterPlatform===================")
      SDKAndroid.sdkcallbacks.enterplatform_callback = callback
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:enterPlatform()
end


--[[--

获取商品列表
-   EG:畅游 支付前 需要先调用getProductList 获取商品列表
-   callback(data) :data 格式{ "productList" , "msg"};
]] 
function SDKAndroid:getProductList(callback)
      print("========================== getProductList============== ");
      SDKAndroid.sdkcallbacks.get_product_list_callback = callback;
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil , please call init method"
          return
      end 
      local  requestMethodAction = {[SDKAndroid.ACTION_CALL_JAVA_METHOD] = SDKAndroid.ACTION_RET_REQUEST_GET_PRODUCT_LIST_METHOD};
      local  reserveJson = json.encode(requestMethodAction);
      user_plugin:reserve(reserveJson);        
end

function SDKAndroid:payForProduct(product, callback)
      print("===============payForProduct===================")
      SDKAndroid.sdkcallbacks.pay_callback = callback
      product[SDKAndroid.APP_ID] = SDKAndroid[SDKAndroid.APP_ID]
      product[SDKAndroid.USER_NAME] = SDKAndroid[SDKAndroid.USER_NAME] 
      product[SDKAndroid.USER_ID] = SDKAndroid[SDKAndroid.USER_ID] 
      product[SDKAndroid.PLATFORM_TOKEN] = SDKAndroid[SDKAndroid.PLATFORM_TOKEN] 
      product[SDKAndroid.PLATFORM] = SDKAndroid[SDKAndroid.PLATFORM] or ""
      local product_string = json.encode(product)
      local iap_plugin = TFSdkManager:getInstance():getIAPPlugin()
      if not iap_plugin then
          print "iap_plugin is nil"
          return
      end 
      iap_plugin:payForProduct(product_string)
end

function SDKAndroid:createRole(role)
      print("===============createRole===================")
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if not user_plugin then
          print "user_plugin is nil"
          return
      end
      user_plugin:createRole(json.encode(role)) 
end

function SDKAndroid:release()
      print("===============release===================")
      local user_plugin = TFSdkManager:getInstance():getUserPlugin()
      if user_plugin then
        user_plugin:releasePlugin()
      end

      local iap_plugin = TFSdkManager:getInstance():getIAPPlugin()
      if iap_plugin then
        iap_plugin:releasePlugin()
      end
end


function SDKAndroid:getSdkName()
      return SDKAndroid[SDKAndroid.PLATFORM]
end

function SDKAndroid:getPlatformToken()
      return SDKAndroid[SDKAndroid.PLATFORM_TOKEN]
end

function SDKAndroid:getCheckServerToken()
      return SDKAndroid[SDKAndroid.TOKEN]
end

function SDKAndroid:getUserID()
      return SDKAndroid[SDKAndroid.USER_ID]
end

function SDKAndroid:getUserName()
      return SDKAndroid[SDKAndroid.USER_NAME]
end

function SDKAndroid:getAppID()
      return SDKAndroid[SDKAndroid.APP_ID]
end

function SDKAndroid:getUserIsLogin()
      local user_plugin = TFSdkManager:getInstance():getUserPlugin();
        if user_plugin then
            return user_plugin:isLogined()
        end
        return false
end

--[[

-   debug 为布尔变量。debug = ture，为调试模式，打开日志输出
]]
function SDKAndroid:setDebugMode(debug)
      if debug then
          if type(debug) =="boolean" then
              local  user_plugin =TFSdkManager:getInstance():getUserPlugin();
              user_plugin:setDebugMode(debug);
              else
                print("debug is invalid , please check this value type");
          end
      end
end

--[[

保留接口
-   paramTable:请求参数(格式：json串, eg: {"action":"100" , "arg0":"xxx" ,"arg1":"xx"}) ; action 请求方法id 
-   listener :回调接口 (格式:function)
-   arg0 ...等参数，视情况而定
]]
function SDKAndroid:reserve(paramTable,listenner)
      print("===============reserve===================")
end

--[[

获取sdk 版本号
-   callback(data) data 为string ,即："2.0.0"
]]
function SDKAndroid:getSdkVersion(callback)
      print("========================== getSdkVersion==============");
      SDKAndroid.sdkcallbacks.get_sdk_version_callback = callback
      local user_plugin = TFSdkManager:getInstance():getUserPlugin();
      if not user_plugin then
          print(" user_plugin is nil , please call init method");
          return 0;
      end
      local  requestMethodAction = {[SDKAndroid.ACTION_CALL_JAVA_METHOD] = SDKAndroid.ACTION_RET_REQUEST_GET_SDK_VERSION};
      local  reserveJson = json.encode(requestMethodAction);
      user_plugin:reserve(reserveJson); 
end

function SDKAndroid:onEventActionID(szEventID)
      print(" =========================onEventActionID ===============");
      local sdkName = TFSdk:getSdkName()
      if not sdkName or sdkName ~= "changyou" then return end
      local user_plugin = TFSdkManager:getInstance():getUserPlugin();
      if not user_plugin then
          print ("user_plugin is nil ,  please call init method");
          return
      end
      local  requestMethodAction = {
            [SDKAndroid.ACTION_CALL_JAVA_METHOD] = SDKAndroid.ACTION_RET_ON_EVENT_ACTION_ID,
            ["eventId" ]= szEventID
      };
      local  reserveJson = json.encode(requestMethodAction);
      user_plugin:reserve(reserveJson); 
end

function SDKAndroid:share(shareContectTab ,callback)
  print("========================== share==============");
  SDKAndroid.sdkcallbacks.share_callback = callback
    local user_plugin = TFSdkManager:getInstance():getUserPlugin();
    if not user_plugin then
      print(" user_plugin is nil , please call init method");
      return;
    end
    shareContectTab[SDKAndroid.ACTION_CALL_JAVA_METHOD] = SDKAndroid.ACTION_RET_REQUEST_SHARE_METHOD;
    local  reserveJson = json.encode(shareContectTab);
    user_plugin:reserve(reserveJson);
end
return SDKAndroid
