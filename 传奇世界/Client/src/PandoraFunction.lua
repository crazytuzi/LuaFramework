-----------------
-- author : suzhen
-----------------

require "cocos/cocos2d/json"
require("src/config/propCfg")

G_isPandoraPay = false
G_isTestEnv = false
G_isInMainScene = false

function _G_PandoraFunction(str)
  --print("suzhen pandora in lua")
  local noerror, ret = pcall(require("json").decode, str)
  if noerror and ret and TOPBTNMG then
    local cmdType = ret.type
    if cmdType == "pandora" then
      if ret.content == "off" then
      	TOPBTNMG.pandoraBtn:setVisible( false )
        G_PandoraIconState.pandoraOn = false
      elseif ret.content == "on" then
      	if G_PandoraIconState.iconShow then
      		TOPBTNMG.pandoraBtn:setVisible( true )
      	end
        G_PandoraIconState.pandoraOn = true
      end
  	end
    if not G_PandoraIconState.pandoraOn then
    	return
    end
    --print("suzhen pandora in lua--")
    if cmdType == "activity_icon" then
      if ret.content == "on" then
        TOPBTNMG.pandoraBtn:setVisible( true )
        G_PandoraIconState.iconShow = true
      elseif ret.content == "off" then
        TOPBTNMG.pandoraBtn:setVisible( false )
        G_PandoraIconState.iconShow = false
      end
    elseif cmdType == "refresh" then
      if ret.content == "gold" or ret.content == "diamond" then
        --pandora购买后重新查询金币或钻石(游戏内只有元宝)
        --require("src/layers/pay/PayMsg")
        --sendSdkPaySucess(0)
        g_msgHandlerInst:sendNetDataByTable(TPAY_CS_CZSUCESS, "TPayCZSucess", {openKey=sdkGetOpenId(), payToken=sdkGetPayToken(),pf=sdkGetPf(), pfKey=sdkGetPfKey(),money=0})
      end
    elseif cmdType == "jump" then
      if ret.content == "recharge" then
        --跳转充值界面
        __GotoTarget( { ru = "a33" } )
      elseif ret.content == "store" then
        --跳转商城界面
        __GotoTarget( { ru = "a12" } )
      elseif ret.content == "mail" then
        --跳转邮箱界面
        __GotoTarget( { ru = "a79" } )
      end
    elseif cmdType == "redpoint" then
        if ret.content == "0" then
          TOPBTNMG.pandoraRedFlag:setVisible( false )
          G_PandoraIconState.flagShow = false
        else
          TOPBTNMG.pandoraRedFlag:setVisible( true )
          G_PandoraIconState.flagShow = true
          if G_isInMainScene == true then
            G_isInMainScene = false
            PandoraShowDialog("activity_panel")
          end
        end
    elseif cmdType == "get_info" then
        if ret.content == "gold" then
          local currGold = MRoleStruct:getAttr(PLAYER_INGOT)
          local gold_Table = {}
          gold_Table["type"] = "get_info_result"
          gold_Table["content"] = string.format(currGold) 
          local jsonStringRes = json.encode(gold_Table)
          PandoraSendMessage(jsonStringRes)
        end
    elseif cmdType == "pay" then
      local zoneId = ret.content.zoneId
      local offerId = ret.content.offerId
      local goodsTokenUrl = ret.content.goodsTokenUrl
      if goodsTokenUrl then
        sdkBuyGoods(zoneId, offerId, goodsTokenUrl)
        G_isPandoraPay = true
      end
    elseif cmdType == "item_detail" then
      --print("suzhen utem_detailsssssss")
	    local item_detailTable = {}
	    local item_detailContentTable = {}
      for i = 1, #(ret.content) do
      	local res = getConfigItemByKey("propCfg","q_id",tonumber(ret.content[i]))
        if res.hqtj then
          local x = type(res.hqtj)
          if x ~= "number" then
              local tblS = stringToTable(res.hqtj)
              for idx,tbl in ipairs(tblS) do
                local tblOutputWay = {}
                for idxR,tblR in ipairs(tbl) do
                  --print(idxR,tblR)
                  tblOutputWay[tostring(idxR)] = getConfigItemByKey("PropOutputWay","id",tonumber(idxR),"showname")
                end
                local jsonS = json.encode(tblOutputWay)
                res.hqtj = jsonS
              end
          else
              res.hqtj = getConfigItemByKey("PropOutputWay","id",tonumber(res.hqtj),"showname")
          end
        end
      	local noerror, rets = pcall(require("json").encode, res)
      	  if noerror then
      	  	item_detailContentTable[string.format(ret.content[i])] = rets
            --print("suzhen rets " .. rets)
      	  end
      end
      item_detailTable["type"] = "item_detail_result"
	    item_detailTable["content"] = item_detailContentTable
	    local jsonStringRes = json.encode(item_detailTable)
	    PandoraSendMessage(jsonStringRes)
    end
  end
end

function midasBuyGoodsForPandora(result, message, number)
	if G_isPandoraPay then
        print("suzhen, midas payment for pandora sdk")
        G_isPandoraPay = false
        local payTable = {}
        local payContentTable = {}
        payContentTable["code"] = string.format(result)
        payContentTable["msg"] = string.format(message)
        payContentTable["num"] = string.format(number)
       payTable["type"] = "pay_result"
       payTable["content"] = payContentTable
       local jsonStringRes = json.encode(payTable)
       PandoraSendMessage(jsonStringRes)
    end
end

-- 游戏发出Pandora 登陆的请求
function PandoraLogin(platId,gameAppVersion,openId,areaId,partitionId,roleId,payZoneId,roleName,payToken,appId,accessToken,accType)
	weakCallbackTab.midasBuyGoodsCallBack = midasBuyGoodsForPandora
	local loginTable = {}
	local contentTable = {}
	if platId == true then
		contentTable["platId"] = "1"
	else
		contentTable["platId"] = "0"
	end
	contentTable["gameAppVersion"] = gameAppVersion
	contentTable["openId"] = string.format(openId)
	contentTable["areaId"] = string.format(areaId)
	contentTable["partitionId"] = string.format(partitionId) 
	contentTable["roleId"] = string.format(roleId) 
	contentTable["payZoneId"] = payZoneId
	contentTable["roleName"] = string.format(roleName) 
	contentTable["payToken"] = payToken
	contentTable["appId"] = appId
	contentTable["accessToken"] = accessToken
	contentTable["accType"] = accType
  if G_isTestEnv == true then
    contentTable["game_env"] = "0"
    --print("suzhen ------------- pandoraLogin is TestMode")
  else
    contentTable["game_env"] = "1"
    --print("suzhen ------------- pandoraLogin is not TestMode")
  end

	loginTable["type"] = "login"
	loginTable["content"] = contentTable

	local jsonString = json.encode(loginTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end

--游戏发出Pandora 登录注销的请求
function PandoraLogout()
	local logoutTable = {}
	local contentTable = {}
	contentTable["flag"] = "1"
	logoutTable["type"] = "logout"
	logoutTable["content"] = contentTable

	local jsonString = json.encode(logoutTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end

-- 游戏发出Pandora showDialog的请求
function PandoraShowDialog(DialogFlag)
	local dialogTable = {}
	local contentTable = {}
	dialogTable["type"] = "show"
	dialogTable["content"] = DialogFlag

	local jsonString = json.encode(dialogTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end

-- 游戏发出Pandora关闭所有窗口的请求
function PandoraCloseAllDialog()
	local paramTable = {}
	paramTable["type"] = "close"
	paramTable["content"] = "activity_panel"
	local jsonString = json.encode(paramTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end

-- 游戏发出Pandora清理缓存的请求
function PandoraCleanCache()
	local paramTable = {}
	paramTable["type"] = "callGC"
	paramTable["content"] = ""
	local jsonString = json.encode(paramTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end

-- 游戏发出Pandora彻底退出的请求
function PandoraExit()
	local paramTable = {}
	paramTable["type"] = "exit"
	paramTable["content"] = ""
	local jsonString = json.encode(paramTable)
	PandoraSendMessage(jsonString)
	return jsonString 
end


function PandoraDraw()
	local drawTable = {}
	drawTable["type"] = "draw"
	drawTable["content"] = "pandora"
	PandoraSendMessage(json.encode(drawTable))
end