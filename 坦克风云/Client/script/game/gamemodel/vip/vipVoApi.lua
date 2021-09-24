vipVoApi=
{
	vipVo=nil,
	vipFlag=false,
	vipReward=nil,
	lastCheckRechargeTs=0,	--上次检测充值设备ID的时间
	deviceCanPay=0,			--该设备是否可以充值，五分钟更新一次
	thirdPayCfg=nil,		--第三方支付的开关数据
	activeFlag = nil,
}

function vipVoApi:initWithData(data)
	if(self.vipVo==nil)then
		require "luascript/script/game/gamemodel/vip/vipVo"
		self.vipVo=vipVo:new()
	end
	self.vipVo:update(data)
end

--显示充值面板
--param layerNum 面板要显示的层
function vipVoApi:showRechargeDialog(layerNum,tabIndex,flag)
	local function doShowRecharge()
		if G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="efunandroidhuashuo" or  G_curPlatName()=="efunandroid360" or (G_curPlatName()=="efunandroidtw" and G_Version~=nil and G_Version<18) or G_curPlatName()=="androidom2" then
			local realZoneID=base.curZoneID
			if G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" then	
				if  base.curOldZoneID~=nil and tonumber(base.curOldZoneID)>0 then
					realZoneID=base.curOldZoneID
				end
			end
	        AppStorePayment:shared():buyItemByTypeForAndroid("","","",0,1,"",realZoneID,"","");
	        do return end
	    end
		local isShowMCard=nil
		local cardCfg = vipVoApi:getMonthlyCardCfg()
		if(base.monthlyCardOpen==1 and cardCfg)then
			isShowMCard=true
		end
		self:setAcFlag(flag)
		require "luascript/script/game/scene/gamedialog/vip/vipRechargeDialog"
		local vrd = vipRechargeDialog:new(isShowMCard)
		local vd = vrd:init("panelBg.png",false,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("buyGemsTiTle"),false,layerNum)
		if vd~=nil then
			sceneGame:addChild(vd,layerNum)
		end
	end
	local function showError()
		local tipStr=getlocal("backstage322")
		if(platFormCfg.contactUsInfo)then
			if(type(platFormCfg.contactUsInfo)=="table" and platFormCfg.contactUsInfo[G_getCurChoseLanguage()])then
				tipStr=tipStr.."\n"..platFormCfg.contactUsInfo[G_getCurChoseLanguage()]
			elseif(type(platFormCfg.contactUsInfo)=="string")then
				tipStr=tipStr.."\n"..platFormCfg.contactUsInfo
			end
		end
		local lableTmp=GetTTFLabelWrap(tipStr,28,CCSizeMake(540,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		local height=lableTmp:getContentSize().height
		local realHeight=math.min(height + 250,400)
		smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,realHeight),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tipStr,true,100,nil,true)
	end
	if(base.checkRecharge==1)then
		if(base.serverTime - self.lastCheckRechargeTs>=300)then
			local function onRequestEnd(fn,data)
				local ret,sData=base:checkServerData(data)
				if(ret==true)then
					local devPay=tonumber(sData.data.devPay)
					self.deviceCanPay=devPay
					self.lastCheckRechargeTs=base.serverTime
					if(devPay==1)then
						doShowRecharge()
					else
						showError()
					end
				else
					showError()
				end
			end
			socketHelper:checkRecharge(onRequestEnd)
		else
			if(self.deviceCanPay==1)then
				doShowRecharge()
			else
				showError()
			end
		end
	else
		doShowRecharge()
	end
end

--去充值
--param index: 要充值的档次
--param layerNum: 因为会弹出smalldialog, 所以需要一个smalldialog的layerNum
--param specialFlag: 原来的代码太乱, 有一个特殊处理的逻辑没法重构, 只能在这里新增一个参数来处理
function vipVoApi:gotoRecharge(index,layerNum,specialFlag)
	local curPlatformName = G_curPlatName()
	if base.isPayOpen==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("betaNoRecharge"),28)
		do return end
	end
	if G_getPlatAppID()==10315 or G_getPlatAppID()==10215 or G_getPlatAppID()==10615 or G_getPlatAppID()==11815 or G_getPlatAppID()==1028 then
		local url="http://tank-android-01.raysns.com/tankheroclient/clickpage.php?uid="..(playerVoApi:getUid()==nil and 0 or playerVoApi:getUid()).."&appid="..G_getPlatAppID().."&tm="..base.serverTime.."&tp=btn"
		HttpRequestHelper:sendAsynHttpRequest(url,"")
	end

	local  tmpStoreCfg=G_getPlatStoreCfg()
	global.rechargeFailedNoticed=false --如果充值失败了是否要弹出失败面板 false:弹出  true:不弹
	local sortCfg=playerCfg.recharge.indexSort
	if sortCfg[index] then
		--统计充值
		local  mPrice=tmpStoreCfg["money"][GetMoneyName()][index]
		if G_judgeEncryption(index,mPrice)==true then
			do return end
		end
		statisticsHelper:recharge("orderId",tonumber(mPrice),tonumber(sortCfg[index]),"appStore")
			CCUserDefault:sharedUserDefault():setStringForKey("UserOrderInfo",mPrice..","..sortCfg[index])
			CCUserDefault:sharedUserDefault():flush()

		if PlatformManage~=nil then --判断是否存在PlatformManage类
			if G_isIOS() then
				if curPlatformName=="0" or curPlatformName=="2" or curPlatformName=="5" or G_curPlatName()=="31" or G_curPlatName()=="45" or G_curPlatName()=="48" or G_curPlatName()=="62" then --为0 是appstore平台支付 2:yeahmobi
					if(base.isPay1Open==1)then
                        local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
                        local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
                        local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
                        if platLanTb~=nil then
                            productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
                        end
                        
                        local buy_ext1=""
                        local buy_ext2=""
                        local buy_ext3=""
                        

                        local itemId="tk_gold_"..sortCfg[index]
                        local tmpTb={}
                        tmpTb["action"]="3thpay"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["itemIndex"]=sortCfg[index]
                        tmpTb["parms"]["itemid"]=itemId
                        tmpTb["parms"]["name"]=productName
                        tmpTb["parms"]["desc"]=""
                        tmpTb["parms"]["price"]=mPrice
                        tmpTb["parms"]["count"]=1
                        tmpTb["parms"]["pic"]=""
                        tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
                        tmpTb["parms"]["currency"]=GetMoneyName()
                        tmpTb["parms"]["ext1"]=buy_ext1
                        tmpTb["parms"]["ext2"]=buy_ext2
                        tmpTb["parms"]["ext3"]=buy_ext3
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
					else
						AppStorePayment:shared():buyItemByType(tonumber(sortCfg[index]))
					end					
				elseif curPlatformName=="1" or curPlatformName=="42"  then --为1 是快用平台支付
					if base.platformUserId~=nil then
						local guidStr=Split(base.platformUserId,"_")[2]
						local itemId=tostring(sortCfg[index])
						local itemDesc=getlocal("tk_gold_"..itemId.."_desc")
						local gameUid=tostring(playerVoApi:getUid())
						local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
						local tmpTb={}
						tmpTb["action"]="buyItemByNewKY"
						tmpTb["parms"]={}
						tmpTb["parms"]["fee"]=tostring(mPrice)
						tmpTb["parms"]["subject"]=itemDesc
						tmpTb["parms"]["itemid"]=itemId
						local cjson=G_Json.encode(tmpTb)
						G_accessCPlusFunction(cjson)
					end
				elseif curPlatformName=="3" or curPlatformName=="4"  then --3 是EFUNios平台支付
					PlatformManage:shared():buyItemByType(tonumber(sortCfg[index]))
				elseif curPlatformName=="6" then --91
					local itemId="tk_gold_"..sortCfg[index]
					local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
					local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
					if platLanTb~=nil then
						productName=getlocal("daily_award_tip_3",{G_getPlatStoreCfg()["gold"][index]})
					end
					local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
					local tmpTb={}
					tmpTb["action"]="buyItemByProductId91"
					tmpTb["parms"]={}
					tmpTb["parms"]["productId"]=itemId
					tmpTb["parms"]["productName"]=productName
					tmpTb["parms"]["price"]=mPrice
					local cjson=G_Json.encode(tmpTb)
					G_accessCPlusFunction(cjson)
				elseif curPlatformName=="7" then --pp
					local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
					local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
					local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
					if platLanTb~=nil then
						productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
					end

					local tmpTb={}
					tmpTb["action"]="buyItemByPricePP"
					tmpTb["parms"]={}
					tmpTb["parms"]["price"]=mPrice
					tmpTb["parms"]["billTitle"]=productName
					tmpTb["parms"]["itemId"]=tostring(sortCfg[index])
					tmpTb["parms"]["zoneid"]=base.curZoneID

					local cjson=G_Json.encode(tmpTb)
					G_accessCPlusFunction(cjson)
				elseif curPlatformName=="8" or curPlatformName()=="70" then --TBT
					local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
					local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
					local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
					if platLanTb~=nil then
						productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
					end
					local tmpTb={}
					tmpTb["action"]="buyItemByPriceTBT"
					tmpTb["parms"]={}
					tmpTb["parms"]["price"]=mPrice
					tmpTb["parms"]["desc"]=productName
					tmpTb["parms"]["itemId"]=tostring(sortCfg[index])

					local cjson=G_Json.encode(tmpTb)
					G_accessCPlusFunction(cjson)
				elseif curPlatformName=="9" or curPlatformName=="10" then --飞流越狱
					local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
					local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
					if platLanTb~=nil then
						productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
					end
					local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
					local tmpTb={}
					tmpTb["action"]="buyItemByPriceFeiliu"
					tmpTb["parms"]={}
					tmpTb["parms"]["price"]=mPrice*100 --飞流是以分为单位 所以*100
					tmpTb["parms"]["desc"]=productName
					tmpTb["parms"]["itemId"]=tostring(sortCfg[index])

					local cjson=G_Json.encode(tmpTb)
					G_accessCPlusFunction(cjson)
				else
					if platCfg.platSureBuy[G_curPlatName()]~=nil then									
						local function callBack()
							deviceHelper:luaPrint("ios common buy start");
							local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
							local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
							local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
							if platLanTb~=nil then
								productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
							end
							local buy_ext1=""
							local buy_ext2=""
							local buy_ext3=""
							local itemId="tk_gold_"..sortCfg[index]
							local tmpTb={}
							tmpTb["action"]="buyItemByTypeForIOS"
							tmpTb["parms"]={}
							tmpTb["parms"]["itemIndex"]=sortCfg[index]
							tmpTb["parms"]["itemid"]=itemId
							tmpTb["parms"]["name"]=productName
							tmpTb["parms"]["desc"]=""
							tmpTb["parms"]["price"]=mPrice
							tmpTb["parms"]["count"]=1
							tmpTb["parms"]["pic"]=""
							tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
							tmpTb["parms"]["currency"]=GetMoneyName()
							tmpTb["parms"]["ext1"]=buy_ext1
							tmpTb["parms"]["ext2"]=buy_ext2
							tmpTb["parms"]["ext3"]=buy_ext3
							local cjson=G_Json.encode(tmpTb)
							deviceHelper:luaPrint("ios common buy parms:"..cjson);
							G_accessCPlusFunction(cjson)
							deviceHelper:luaPrint("ios common buy end");
						end
						local mType=tmpStoreCfg["moneyType"][GetMoneyName()]
						local mPrice=tmpStoreCfg["money"][GetMoneyName()][tonumber(index)]
						local moneyStr =getlocal("buyGemsPrice",{mType,mPrice})
						if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
							moneyStr =getlocal("buyGemsPrice",{mPrice,mType})
						end

						local goldNum=tmpStoreCfg["gold"][tonumber(index)]
						smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("sureBuy",{moneyStr,goldNum}),nil,layerNum+1)
					else
						deviceHelper:luaPrint("ios common buy start");
						local productName=getlocal("tk_gold_"..sortCfg[index].."_desc")
						local mPrice=tonumber(tmpStoreCfg["money"][GetMoneyName()][tonumber(index)])
						local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
						if platLanTb~=nil then
							productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
						end
						local buy_ext1=""
						local buy_ext2=""
						local buy_ext3=""
						local itemId="tk_gold_"..sortCfg[index]
						local tmpTb={}
						tmpTb["action"]="buyItemByTypeForIOS"
						tmpTb["parms"]={}
						tmpTb["parms"]["itemIndex"]=sortCfg[index]
						tmpTb["parms"]["itemid"]=itemId
						tmpTb["parms"]["name"]=productName
						tmpTb["parms"]["desc"]=""
						tmpTb["parms"]["price"]=mPrice
						tmpTb["parms"]["count"]=1
						tmpTb["parms"]["pic"]=""
						tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
						tmpTb["parms"]["currency"]=GetMoneyName()
						tmpTb["parms"]["ext1"]=buy_ext1
						tmpTb["parms"]["ext2"]=buy_ext2
						tmpTb["parms"]["ext3"]=buy_ext3
						local cjson=G_Json.encode(tmpTb)
						deviceHelper:luaPrint("ios common buy parms:"..cjson);
						G_accessCPlusFunction(cjson)
						deviceHelper:luaPrint("ios common buy end");
					end
				end
			else
				if platCfg.platSureBuy[G_curPlatName()]~=nil then
					local function callBack()
						local ext1=""
						if curPlatformName=="efunandroidtw" or curPlatformName=="efunandroiddny" then
							local shopItemArr={"one","two","three","four","five","six","seven","eight","nine","ten"} 
							ext1 = "pay"..shopItemArr[tonumber(sortCfg[index])]
						end
						local itemId="tk_gold_"..sortCfg[index]
						local itemDesc=getlocal(itemId.."_desc")
						local mPrice=tmpStoreCfg["money"][GetMoneyName()][tonumber(index)]

						local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
						if platLanTb~=nil then
							itemDesc=getlocal("daily_award_tip_3",{G_getPlatStoreCfg()["gold"][index]})
						end
						local theGoldNum=tmpStoreCfg["gold"][index]
						ext2 = theGoldNum
						if specialFlag==1 then  --俄罗斯安卓第三方支付按钮
							if curPlatformName=="efunandroiddny" then
								ext2 = "1"
							else
								ext1 = "1"
							end
						end

						AppStorePayment:shared():buyItemByTypeForAndroid(itemId,itemDesc,"",mPrice,1,"",base.curZoneID,ext1,ext2);
					end
						
					local mType=tmpStoreCfg["moneyType"][GetMoneyName()]
					local mPrice=tmpStoreCfg["money"][GetMoneyName()][tonumber(index)]
					local moneyStr =getlocal("buyGemsPrice",{mType,mPrice})
					if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
						moneyStr =getlocal("buyGemsPrice",{mPrice,mType})
					end
					local goldNum=tmpStoreCfg["gold"][tonumber(index)]
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("sureBuy",{moneyStr,goldNum}),nil,layerNum+1)
				else
					local ext1=""
					if curPlatformName=="efunandroidtw" or curPlatformName=="efunandroiddny" then
						local shopItemArr={"one","two","three","four","five","six","seven","eight","nine","ten"} 
						ext1 = "pay"..shopItemArr[tonumber(sortCfg[index])]
					end
					local itemId="tk_gold_"..sortCfg[index]
					local itemDesc=getlocal(itemId.."_desc")
					local mPrice=tmpStoreCfg["money"][GetMoneyName()][tonumber(index)]

					local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
					if platLanTb~=nil then
						itemDesc=getlocal("daily_award_tip_3",{G_getPlatStoreCfg()["gold"][index]})
					end
					local theGoldNum=tmpStoreCfg["gold"][index]
					ext2 = theGoldNum
					if specialFlag==1 then  --俄罗斯安卓第三方支付按钮
						if curPlatformName=="efunandroiddny" then
							ext2 = "1"
						else
							ext1 = "1"
						end
					end
					AppStorePayment:shared():buyItemByTypeForAndroid(itemId,itemDesc,"",mPrice,1,"",base.curZoneID,ext1,ext2);
				end
			end
		else
			AppStorePayment:shared():buyItemByType(tonumber(sortCfg[index]))
		end
	end
end

--购买月卡
function vipVoApi:buyMonthlyCard(layerNum)
	local curPlatformName = G_curPlatName()
	local cardCfg=vipVoApi:getMonthlyCardCfg()
	if(cardCfg==nil or base.monthlyCardBuyOpen~=1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_notOpen"),28)
		do return end
	end
	local leftDays=self:getMonthlyCardLeftDays()
	if(leftDays>cardCfg.effectiveDays)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_monthlyCard_error1",{cardCfg.effectiveDays}),28)
		do return end
	end
	if base.isPayOpen==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("betaNoRecharge"),28)
		do return end
	end

	global.rechargeFailedNoticed=false --如果充值失败了是否要弹出失败面板 false:弹出  true:不弹
	--统计充值
	local mPrice=cardCfg["money"][GetMoneyName()]
	statisticsHelper:recharge("orderId",tonumber(mPrice),tonumber(cardCfg.id),"appStore")
		CCUserDefault:sharedUserDefault():setStringForKey("UserOrderInfo",mPrice..",7")
		CCUserDefault:sharedUserDefault():flush()

	local platId=G_getServerPlatId()

    local flag, status, rlimit = healthyApi:getHealthyRechargeStatus(mPrice)
    if flag == false then
        local str = getlocal("healthy_recharge_tip"..status, {rlimit})
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("healthy_tip"), str, nil, 8)
        do return end
    end

	if PlatformManage~=nil then --判断是否存在PlatformManage类
		if(base.webpageRecharge == 1)then --网页支付
            local tmpTb = {}
            tmpTb["action"] = "openUrl"
            tmpTb["parms"] = {}
            local platID = G_getUserPlatID()
            if G_curPlatName() ~= "51" then
            	local index = string.find(platID, "_")
	            if(index)then
	                platID = string.sub(platID, index + 1)
	            else
	                platID = nil
	            end	
            end
 
            local url = "http://"..base.serverUserIp
            if(G_curPlatName() == "androidsevenga" or G_curPlatName() == "11")then
                
            else
                local zoneID
                if(base.curOldZoneID and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "")then
                    zoneID = base.curOldZoneID
                else
                    zoneID = base.curZoneID
                end
                -- url = url.."/tank_rayapi/index.php/iapppayweb?game_user_id="..playerVoApi:getUid() .. "&zoneid="..zoneID.."&itemid="..sortCfg[selectIndex] .. "&channel="..G_curPlatName() .. "&os=ios"
                -- if(platID)then
                --     url = url.."&platform_user_id="..platID
                -- end
                --由于爱贝被查，该支付废弃，暂时接入雷神天津那边的微信支付宝网页支付
                url = "http://gd-weiduan-sdk02.leishenhuyu.com/rsdk-base-server/pay/create_order/1010001000/h5rgame-1010001001/v1"
                local productId = cardCfg.id
                local productName = HttpRequestHelper:URLEncode(getlocal("tk_gold_"..productId.."_desc"))
                local mPrice = tonumber(mPrice)
                local goldNum = cardCfg.goldFirst
                local channelId = G_curPlatName() .. "___"..G_getServerPlatId() --渠道名和平台名，G_getServerPlatId是sdk那边区分域名用
                -- if G_getServerPlatId()=="fl_yueyu" then --越狱平台老包因为“|”问题有些包打不开链接
                --     -- productName = goldNum.."gold"
                --     channelId = G_curPlatName().."___"..G_getServerPlatId()
                -- end
                if tonumber(playerVoApi:getUid()) == 1000000487 and tonumber(base.curZoneID)==1000 then --测试账号
                    mPrice = 1.00
                end
                if self:isSandboxAccount() == true then --测试账号
            		mPrice = 1.00
                end
                local params = "product_id="..productId.."&game_server_id="..zoneID.."&product_count=1" .. "&product_name="..productName.."&platform_user_id=" .. (platID or "") .. "&game_user_id="..playerVoApi:getUid() .. "&private_data="..channelId.."&cost="..mPrice.."&coin_num="..goldNum.."&os=h5&product_type=gold" .. "&wares_id=1&nonce_str="..tostring(G_getCurDeviceMillTime())
                url = url .. "?" .. params
            end
            tmpTb["parms"]["url"] = url
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
            do return end
        end
		if G_isIOS() then
			if curPlatformName == "0" or curPlatformName=="2" or curPlatformName=="5" or G_curPlatName()=="31" or G_curPlatName()=="45" or G_curPlatName()=="51" or G_curPlatName()=="48" or G_curPlatName()=="62" then --为0 是appstore平台支付 2:yeahmobi
					if(base.isPay1Open==1)then
                        local productName=getlocal("tk_gold_"..cardCfg.id.."_desc")
                        local mPrice=tonumber(mPrice)
                        local platLanTb=platCfg.platCfgStoreDesc[G_curPlatName()]
                        if platLanTb~=nil then
                            productName=getlocal("daily_award_tip_3",{localCfg["gold"][index]})
                        end
                        
                        local buy_ext1=""
                        local buy_ext2=""
                        local buy_ext3=""
                        

                        local itemId="tk_gold_"..cardCfg.id
                        local tmpTb={}
                        tmpTb["action"]="3thpay"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["itemIndex"]=cardCfg.id
                        tmpTb["parms"]["itemid"]=itemId
                        tmpTb["parms"]["name"]=productName
                        tmpTb["parms"]["desc"]=""
                        tmpTb["parms"]["price"]=mPrice
                        tmpTb["parms"]["count"]=1
                        tmpTb["parms"]["pic"]=""
                        tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
                        tmpTb["parms"]["currency"]=GetMoneyName()
                        tmpTb["parms"]["ext1"]=buy_ext1
                        tmpTb["parms"]["ext2"]=buy_ext2
                        tmpTb["parms"]["ext3"]=buy_ext3
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
					else
						AppStorePayment:shared():buyItemByType(tonumber(cardCfg.id))
					end
				
			elseif curPlatformName=="1" then --为1 是快用平台支付
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
			elseif curPlatformName=="3" or curPlatformName=="4"  then --3 是EFUNios平台支付
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
			elseif curPlatformName=="6" then --91
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
			elseif curPlatformName=="7" then --pp
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
			elseif curPlatformName=="8" or curPlatformName == "70" then --TBT
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
				local productName = getlocal("tk_gold_"..cardCfg.id .. "_desc")
                local mPrice = tonumber(cardCfg["money"][GetMoneyName()])
                -- local platLanTb = platCfg.platCfgStoreDesc[curPlatformName]
                -- if platLanTb ~= nil then
                --     productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                -- end
                local tmpTb = {}
                tmpTb["action"] = "buyItemByPriceTBT"
                tmpTb["parms"] = {}
                tmpTb["parms"]["price"] = mPrice
                tmpTb["parms"]["desc"] = productName
                tmpTb["parms"]["itemId"] = cardCfg.id
                
                local cjson = G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
			elseif curPlatformName=="9" or curPlatformName=="10" then --飞流越狱
				--不上军需卡功能, 代码删掉了, 以后上的时候再加
			else
				if platCfg.platSureBuy[G_curPlatName()]~=nil then									
					local function callBack()
						deviceHelper:luaPrint("ios common buy start");
						local productName=getlocal("vip_monthlyCard")
						local mPrice=tonumber(cardCfg["money"][GetMoneyName()])
						local buy_ext1=""
						local buy_ext2=""
						local buy_ext3=""
						local itemId="tk_gold_"..cardCfg.id
						local tmpTb={}
						tmpTb["action"]="buyItemByTypeForIOS"
						tmpTb["parms"]={}
						tmpTb["parms"]["itemIndex"]=cardCfg.id
						tmpTb["parms"]["itemid"]=itemId
						tmpTb["parms"]["name"]=productName
						tmpTb["parms"]["desc"]=""
						tmpTb["parms"]["price"]=mPrice
						tmpTb["parms"]["count"]=1
						tmpTb["parms"]["pic"]=""
						tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
						tmpTb["parms"]["currency"]=GetMoneyName()
						tmpTb["parms"]["ext1"]=buy_ext1
						tmpTb["parms"]["ext2"]=buy_ext2
						tmpTb["parms"]["ext3"]=buy_ext3
						local cjson=G_Json.encode(tmpTb)
						deviceHelper:luaPrint("ios common buy parms:"..cjson);
						G_accessCPlusFunction(cjson)
						deviceHelper:luaPrint("ios common buy end");
					end
					local mType=G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
					local mPrice=cardCfg["money"][GetMoneyName()]
					local moneyStr=getlocal("buyGemsPrice",{mType,mPrice})
					if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
						moneyStr =getlocal("buyGemsPrice",{mPrice,mType})
					end
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("sureBuy_monthlyCard",{moneyStr}),nil,layerNum+1)
				else
					deviceHelper:luaPrint("ios common buy start");
					local productName=getlocal("vip_monthlyCard")
					local mPrice=tonumber(cardCfg["money"][GetMoneyName()])
                	if self:isSandboxAccount() == true then --测试账号
                		mPrice = 1.00
                	end
					local buy_ext1=""
					local buy_ext2=""
					local buy_ext3=""
					local itemId="tk_gold_"..cardCfg.id
					local tmpTb={}
					tmpTb["action"]="buyItemByTypeForIOS"
					tmpTb["parms"]={}
					tmpTb["parms"]["itemIndex"]=cardCfg.id
					tmpTb["parms"]["itemid"]=itemId
					tmpTb["parms"]["name"]=productName
					tmpTb["parms"]["desc"]=""
					tmpTb["parms"]["price"]=mPrice
					tmpTb["parms"]["count"]=1
					tmpTb["parms"]["pic"]=""
					tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
					tmpTb["parms"]["currency"]=GetMoneyName()
					tmpTb["parms"]["ext1"]=buy_ext1
					tmpTb["parms"]["ext2"]=buy_ext2
					tmpTb["parms"]["ext3"]=buy_ext3
					local cjson=G_Json.encode(tmpTb)
					deviceHelper:luaPrint("ios common buy parms:"..cjson);
					G_accessCPlusFunction(cjson)
					deviceHelper:luaPrint("ios common buy end");
				end
			end
		else
			if platCfg.platSureBuy[G_curPlatName()]~=nil then
				local function callBack()
					local ext1=""
					if curPlatformName=="efunandroidtw" or curPlatformName=="efunandroiddny" then
						--不上军需卡功能, 代码删掉了, 以后上的时候再加
					end
					local itemId="tk_gold_"..cardCfg.id
					local itemDesc=getlocal(itemId.."_desc")
					local mPrice=tonumber(cardCfg["money"][GetMoneyName()])

					local theGoldNum=cardCfg["goldFirst"]
					ext2 = theGoldNum
					AppStorePayment:shared():buyItemByTypeForAndroid(itemId,itemDesc,"",mPrice,1,"",base.curZoneID,ext1,ext2);
				end
						
				local mType=G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
				local mPrice=tonumber(cardCfg["money"][GetMoneyName()])
				local moneyStr=getlocal("buyGemsPrice",{mType,mPrice})
				if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
					moneyStr =getlocal("buyGemsPrice",{mPrice,mType})
				end
				smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("sureBuy_monthlyCard",{moneyStr}),nil,layerNum+1)
			else
				local ext1=""
				if curPlatformName=="efunandroidtw" or curPlatformName=="efunandroiddny" then
					--不上军需卡功能, 代码删掉了, 以后上的时候再加
				end
				local itemId="tk_gold_"..cardCfg.id
				local itemDesc=getlocal(itemId.."_desc")
				local mPrice=tonumber(cardCfg["money"][GetMoneyName()])

				local theGoldNum=cardCfg["goldFirst"]
				ext2 = theGoldNum

				local curZid = vipVoApi:getPayZoneId() --服务器id
				AppStorePayment:shared():buyItemByTypeForAndroid(itemId,itemDesc,"",mPrice,1,"",curZid,ext1,ext2);
			end
		end
	else
		--不上军需卡功能, 代码删掉了, 以后上的时候再加
	end
end

--获取月卡剩余的天数
function vipVoApi:getMonthlyCardLeftDays()
	if(self.vipVo==nil)then
		return 0
	end
	local expireTime=self.vipVo.monthlyCardExpireTime
	local todayST=G_getWeeTs(base.serverTime)
	local leftSeconds=expireTime - todayST
	local leftDays=math.ceil(leftSeconds/86400)
	-- print("leftDays",leftDays)
	if(leftDays>0)then
		return leftDays
	else
		return 0
	end
end

--检查当前是否可以领取月卡
function vipVoApi:checkCanGetMonthlyCardReward()
	local todayST=G_getWeeTs(base.serverTime)
	if(self.vipVo==nil)then
		return false
	end
	if(self.vipVo.monthlyCardExpireTime>todayST and self.vipVo.monthlyCardLastGet<todayST)then
		return true
	else
		return false
	end
end

--领取月卡奖励
function vipVoApi:getMonthlyCardReward(callBack)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			if(callBack~=nil)then
				callBack()
			end
		end
	end
	socketHelper:getMonthlyCardReward(onRequestEnd)
end

--支付成功的回调, 收到后台推来的消息, 从global挪到这里面来
--param result 后台推来的消息
function vipVoApi:onPayment(result)
	local beforeGems=playerVoApi:getGems()
	local beforeBuyGems=tonumber(playerVoApi:getBuygems())
	local beforeVip=playerVoApi:getVipLevel()
	-- 活动充值基金
	local beforeRechargeNum = playerVoApi:getRechargeNum()
	-- 天天基金活动总基金
	local beforeFund = playerVoApi:getAllFund()
	base:formatPlayerData(result)
	if result.ret==0 then
        G_statisticsAuditRecord(AuditOp.RECHARGE_SUCCESS) --记录充值成功
	else
        G_statisticsAuditRecord(AuditOp.RECHARGE_FAIL) --记录充值失败
	end
	if result.ret==0 or result.ret==-128 then
		base:reSetSendPayParms()
		local itemKey, itemId
		if result.data.payment and result.data.payment.itemId then
			itemId = result.data.payment.itemId
			local arr = Split(result.data.payment.itemId, "_")
			if arr and arr[3] then
				itemKey = tonumber(arr[3])
			else
				itemKey = tounmber(itemId)
			end
			result.data.payment.itemId = itemKey
		end
		local cardCfg = vipVoApi:getMonthlyCardCfg()
		if(base.monthlyCardOpen==1 and cardCfg and result.data.payment and tonumber(result.data.payment.num)==cardCfg.goldFirst)then
		elseif itemKey and (itemKey == 201 or itemKey == 202 or itemKey == 203 or tonumber(itemKey) > 203) then --神秘宝箱活动给物品，不弹购买金币提示
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("vip_tequanlibao_goumai_success"),nil,20)
		else
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
		end
		eventDispatcher:dispatchEvent("user.pay",result.data.payment)
		eventDispatcher:dispatchEvent("user.pay.push",result.data)
		--统计充值成功
		
		if result.data.payment~=nil then
			local GoodsCount=result.data.payment.GoodsCount
			local num=tonumber(result.data.payment.num)
			local orderId=result.data.payment.orderId
			local amount=result.data.payment.amount
			if(beforeBuyGems==nil or beforeBuyGems<=0)then
			-- if(true)then
				if(G_curPlatName()=="11" or G_curPlatName()=="androidsevenga" or G_curPlatName()=="0")then
					vipVoApi:movgaFirstRecharge(num)
				end
			end			
			if(base.monthlyCardOpen==1 and num==cardCfg.goldFirst)then
			else
				activityVoApi:updateByRecharge(num) -- 添加充值金额
			end
			statisticsHelper:rechargeSuccess(GoodsCount,num,(itemId or ""),orderId,amount)
		end
	elseif result.ret==-126 then
		if global.rechargeFailedNoticed==false then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldFailure"),nil,20)
			global.rechargeFailedNoticed=true
		end
	elseif result.ret==-9001 or result.ret==-9002 then
		base:reSetSendPayParms()
	elseif result.ret==-322 then
		local tipStr=getlocal("backstage322")
		if(platFormCfg.contactUsInfo)then
			if(type(platFormCfg.contactUsInfo)=="table" and platFormCfg.contactUsInfo[G_getCurChoseLanguage()])then
				tipStr=tipStr.."\n"..platFormCfg.contactUsInfo[G_getCurChoseLanguage()]
			elseif(type(platFormCfg.contactUsInfo)=="string")then
				tipStr=tipStr.."\n"..platFormCfg.contactUsInfo
			end
		end
		local lableTmp=GetTTFLabelWrap(tipStr,28,CCSizeMake(540,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		local height=lableTmp:getContentSize().height
		local realHeight=math.min(height + 250,400)
		smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,realHeight),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tipStr,true,100,nil,true)
	end
	local nowVip=playerVoApi:getVipLevel()
	if nowVip>beforeVip then
		--巨兽崛起这个包的特殊需求，vip升级的时候不发公告
		if(G_curPlatName()~="51")then
			local paramTab={}
			paramTab.functionStr="vip"
			paramTab.addStr="immediate_recharge"
        	paramTab.colorStr="w,b,w,y,w,y"
        	local playerName="<rayimg>" .. playerVoApi:getPlayerName() .."<rayimg>"
        	local vipStr="<rayimg>" .. getlocal("help1_t1_t1") .. nowVip .."<rayimg>"
			local message={key="vipUpgradeMessage",param={playerName,vipStr}}
			chatVoApi:sendSystemMessage(message,paramTab)
		end
        -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
		local params = {key="vipUpgradeMessage",param={{playerVoApi:getPlayerName(),1},{nowVip,8}}}
        chatVoApi:sendUpdateMessage(41,params)
	end
	-- 限时惊喜活动统计需求
	local afterRechargeNum = playerVoApi:getRechargeNum()
	local flag = vipVoApi:getAcFlag()

	if afterRechargeNum and flag and beforeRechargeNum < giftPushVoApi:rechargeNum() and afterRechargeNum>=giftPushVoApi:rechargeNum() and flag =="xsjx" then
		local function callback(fn,data)
		local ret,sData=base:checkServerData(data)
			if ret == true  then
			end
		end
		socketHelper:xsjxDadian(3,callback)
	end
	
	local nowFund = playerVoApi:getAllFund()
	if nowFund < beforeFund then
		local paramTab = {}
		paramTab.functionStr="ttjj"
		paramTab.addStr="goTo_see_see"
		paramTab.colorStr="w,w,y"
        local playerName = playerVoApi:getPlayerName() 
		local message = {key="activity_ttjj_getSystemMessage",param={playerName}}
		chatVoApi:sendSystemMessage(message,paramTab)
	end
end

--movga首充统计需求
function vipVoApi:movgaFirstRecharge(num)
	local tmpTb={}
	tmpTb["action"]="customAction"
	tmpTb["parms"]={}
	tmpTb["parms"]["value"]="getCurrency"
	local cjson=G_Json.encode(tmpTb)
	local moneyName=G_accessCPlusFunction(cjson)
	if(moneyName~="EUR" and moneyName~="CHF")then
		moneyName="EUR"
	end
	local tmpTb={}
	tmpTb["action"]="customAction"
	tmpTb["parms"]={}
	tmpTb["parms"]["value"]="sendFirstChargeData"
	tmpTb["parms"]["current"]=moneyName
	tmpTb["parms"]["time"]=G_keepNumber((base.serverTime - playerVoApi:getRegdate())/86400,2)
	local storeCfg=G_getPlatStoreCfg()
	local priceCfg=storeCfg.money[moneyName]
	local goldCfg=storeCfg.gold
	local key
	for k,v in pairs(goldCfg) do
		if(tonumber(v)==num)then
			key=k
			break
		end
	end
	local price
	if(priceCfg and key and priceCfg[key])then
		price=tonumber(priceCfg[key])
	end
	local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]
	local bLv
	if buildVo and buildVo.level then
		bLv=tonumber(buildVo.level)
	else
		bLv=1
	end
	if(price==nil)then
		price=0
	end
	tmpTb["parms"]["amountMoney"]=price
	tmpTb["parms"]["userLevel"]=playerVoApi:getPlayerLevel()
	tmpTb["parms"]["commandLevel"]=bLv
	tmpTb["parms"]["achievedLevel"]=checkPointVoApi:getUnlockSid()
	if(playerVoApi:getPlayerAid()==nil or tonumber(playerVoApi:getPlayerAid())==0)then
		tmpTb["parms"]["legionState"]=0
	else
		tmpTb["parms"]["legionState"]=1
	end
	tmpTb["parms"]["power"]=playerVoApi:getPlayerPower()
	local cjson=G_Json.encode(tmpTb)
	G_accessCPlusFunction(cjson)
end

--显示等待队列已满, 加速或者去升级vip的提示
--param type: 1为建筑 2为生产坦克 3为改装坦克 4为科技研究 5为道具生产 6为出战部队
--param speedCallback: 加速完成之后的回调
--param data: 一些队列需要传参数进来
function vipVoApi:showQueueFullDialog(type,layerNum,speedCallback,data)
	require "luascript/script/game/scene/gamedialog/vip/vipQueueDialog"
	local vd = vipQueueDialog:new(type)
	vd:init(layerNum,speedCallback,data)
	return vd
end

function vipVoApi:setVipFlag(flag)
	self.vipFlag=flag
end

function vipVoApi:getVipFlag()
	return self.vipFlag
end

function vipVoApi:setVipReward(reward)
	self.vipReward = reward or {}
	local sortFunc = function(a, b) return a.sortID < b.sortID end
	table.sort(self.vipReward, sortFunc)
end

function vipVoApi:getVipReward(idx)
	return self.vipReward[idx].reward
end

function vipVoApi:getVipContent(idx)
	return self.vipReward[idx].contect
end

function vipVoApi:getVipRewardFlick(idx)
	return self.vipReward[idx].flick
end

function vipVoApi:setRealReward(id)
	for k,v in pairs(self.vipReward) do
		if v.id == id then
			table.remove(self.vipReward,k)
			return
		end
	end
	local sortFunc = function(a, b) return a.sortID < b.sortID end
	table.sort(self.vipReward, sortFunc)
end

function vipVoApi:setVf(vf)
	self.vf = vf
end

function vipVoApi:getVf(vf)
	if self.vf==nil then
	  self.vf={}
	end
	return self.vf
end

function vipVoApi:InsertVf(id)
	table.insert(self.vf,id)
end

function vipVoApi:getVip(idx)
	return self.vipReward[idx].vip
end

function vipVoApi:getPrice(idx)
	return self.vipReward[idx].price
end

function vipVoApi:getRealPrice(idx)
	return self.vipReward[idx].realPrice
end

function vipVoApi:getId(idx)
	return self.vipReward[idx].id
end

function vipVoApi:openVipDialog(layerNum,isNew)
	-- isNew=false
	require "luascript/script/game/scene/gamedialog/vipDialogFinal"
	local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
	local vd1 = vipDialogFinal:new(isNew)
    local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,layerNum)       
    sceneGame:addChild(vd,layerNum)
    return vd1
	-- if isNew and isNew==true then
	-- 	require "luascript/script/game/scene/gamedialog/vipDialogNew"    
 --        local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
 --        local vd1 = vipDialogNew:new()
 --        local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,layerNum)       
 --        sceneGame:addChild(vd,layerNum)
 --        return vd1
	-- else
	-- 	require "luascript/script/game/scene/gamedialog/vipDialog"
	-- 	local vd1 = vipDialog:new()
	-- 	local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,layerNum)
	-- 	sceneGame:addChild(vd,layerNum)
	-- 	return vd1
	-- end
end

function vipVoApi:getCanRewardNum()
	local num=0
	local vfTab=G_clone(self:getVf())
	local tmpVf={}
	for k,v in pairs(vfTab) do
		tmpVf["id"..v]=v
	end
	if self.vipReward then
		local curVipLv=playerVoApi:getVipLevel()
		for k,v in pairs(self.vipReward) do
			local id=self:getId(k)
			if tmpVf["id"..id] and tmpVf["id"..id]==id then
			else
				local needVipLv=self:getVip(k)
				if curVipLv>=needVipLv then
					if self:getPrice(k)==0 then
						num=num+1
					-- else
					-- 	local price=self:getRealPrice(k)
					-- 	if playerVoApi:getGems()>=price then

					-- 		num=num+1
					-- 	end
					end
				end
			end 
		end
	end
	return num
end

--检查德国第三方支付是否开启
function vipVoApi:checkThirdPayExists()
	if playerVoApi:getBuygems()==0 then --玩家购买金币数为0时，不显示第三方支付方式
        do return false end
    end
	if(self.thirdPayCfg)then
		if(self.thirdPayCfg.level and playerVoApi:getPlayerLevel()<tonumber(self.thirdPayCfg.level))then
			return false
		end
		if(self.thirdPayCfg.time and (base.serverTime<tonumber(self.thirdPayCfg.time["st"]) or base.serverTime>tonumber(self.thirdPayCfg.time["et"])))then
			return false
		end
		if(self.thirdPayCfg.vip and playerVoApi:getVipLevel()<tonumber(self.thirdPayCfg.vip))then
			return false
		end
		return true
	end
	return false
end

function vipVoApi:setAcFlag(flag)
	self.activeFlag = flag
end

function vipVoApi:getAcFlag( ... )
	return self.activeFlag
end

--获取支付传的服务器id
function vipVoApi:getPayZoneId()
	local curZid = G_mappingZoneid()               
    if base.curOldZoneID ~= nil and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" then
        curZid = base.curOldZoneID
        if G_curPlatName() == "qihoo" or G_curPlatName() == "androidqihoohjdg" then
            if tonumber(base.curZoneID) >= 220 and tonumber(base.curZoneID) < 1000 then
                do
                    curZid = tostring(tonumber(base.curOldZoneID) - 94)
                end
            end
            if tonumber(base.curZoneID) == 1000 or tonumber(base.curZoneID) == 997 or tonumber(base.curZoneID) == 998 then
            	curZid = base.curOldZoneID
            end
        end
    end
    return curZid
end

--获取平台月卡配置
function vipVoApi:getMonthlyCardCfg()
	local cardCfg=platCfg.monthlyCardCfg[G_curPlatName()]
	local platId = G_getServerPlatId()
	if platCfg.platMonthlyCardCfg and platCfg.platMonthlyCardCfg[platId] then
		cardCfg = platCfg.platMonthlyCardCfg[platId]
	end
	return cardCfg
end

--是否是支付测试账号
function vipVoApi:isSandboxAccount()
	local platId = G_getServerPlatId()
	if platId == "fl_yueyu" then
		local uid = tonumber(playerVoApi:getUid())
		if uid == 2038608 or uid == 1000000196 then
			return true
		end
	end
	return false
end

function vipVoApi:clear()
	self.vipVo=nil
	self.vipFlag=false
	self.vipReward=nil
	self.lastCheckRechargeTs=0
	self.deviceCanPay=0
	self.activeFlag=nil
	self.thirdPayCfg=nil
end