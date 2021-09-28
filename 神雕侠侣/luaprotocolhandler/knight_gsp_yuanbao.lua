local sreqcharge = require "protocoldef.knight.gsp.yuanbao.sreqcharge"
function sreqcharge:process()
	print("enter sreqcharge process ")
	require "ui.chargedialog"

	ChargeDialog.getInstance():ResetAllProducts()

	require "utils.tableutil"
	local yuanbao_max = 0
	for k,v in ipairs(self.goods) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v.goodid)
		if item.maxcash == 1 then
			yuanbao_max = v.goodid
			break
		end
	end
	
	for k,v in ipairs(self.goods) do
		ChargeDialog.getInstance():AddGood(k, v.goodid, v.price, v.yuanbao, v.present, v.beishu, yuanbao_max)
	end
end

local sconfirmcharge = require "protocoldef.knight.gsp.yuanbao.sconfirmcharge"
function sconfirmcharge:process()
	LogInfo("enter sconfirmcharge process")

    -- JSON  {"customInfo":"3031062677","roleId":"405506","roleName":"xxxx","roleGrade":"1","amount":"1000","serverid":"1"}

    local json = '{"customInfo":"'
    .. tostring(self.billid)
    .. '",'
    .. '"roleId":"'
    .. tostring(GetDataManager():GetMainCharacterID())
    .. '",'
    .. '"roleName":"'
    .. GetDataManager():GetMainCharacterName()
    .. '",'
    .. '"roleGrade":"'
    .. tostring(GetDataManager():GetMainCharacterLevel())
    .. '",'
    .. '"amount":"'
    .. tostring(self.price)
    .. '",'
    .. '"serverid":"'
    .. tostring(self.serverid)
    .. '"}'

    local goodname = self.goodname
    
    if Config.CUR_3RD_PLATFORM == "efunios" then
        record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        goodname = record.productstr
    end
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
            goodname = goodname .. "#" .. record.productstr
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
        if GetDataManager() and GetDataManager():GetMainCharacterLevel() then
            goodname = goodname .. "#" .. tostring(GetDataManager():GetMainCharacterLevel())
        else
            LogInfo("___error note get character level")
            goodname = goodname .. "#" .. " "
        end
    end
    
    
    if  Config.isKoreanAndroid() then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
            goodname = goodname .. "#" .. record.productstr
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end

	end
    
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "thlm" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
            goodname = goodname .. "#" .. record.productstr
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
    end

    if Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_LOGIN_SUFFIX == "this" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
            goodname =  record.productstr
        end
    end
    

    
    if Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_LOGIN_SUFFIX == "kris" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            print("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
            goodname =  record.productstr
        end
    end
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end
        
        if record and record.id ~= -1 and record.productstr then
            LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr .. "record.fujiadaima: " .. record.fujiadaima)
            goodname = goodname .. "#" .. record.productstr .. "#" .. record.fujiadaima
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
    end
    
	
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
		if self.goodid then
			local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
			goodname = record.productstr	
			if not string.find(record.roofid, "ydjd") then
				return
			end
		end
	end
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ximi" then
        require "luaj"
        require "ui.vip.vipmanager"
        require "ui.faction.factiondatamanager"

        local curUserData = {}
        local blankStr = " "
        if GetDataManager() and GetDataManager():GetYuanBaoNumber() then
            curUserData[1] = tostring(GetDataManager():GetYuanBaoNumber())
        else
            curUserData[1] = blankStr
        end
        if VipManager.GetCurVIPLevel() then
            curUserData[1] = curUserData[1] .. "#vip" .. VipManager.GetCurVIPLevel()
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end
        if GetDataManager() and GetDataManager():GetMainCharacterLevel() then
            curUserData[1] = curUserData[1] .. "#" .. tostring(GetDataManager():GetMainCharacterLevel())
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end
        
        local bGet, facName = FactionDataManager.GetCurFactionName()
        if bGet then
            curUserData[1] = curUserData[1] .. "#" .. facName
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end

        if GetDataManager() and GetDataManager():GetMainCharacterID() then
            curUserData[1] = curUserData[1] .. "#" .. GetDataManager():GetMainCharacterID()
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end

        luaj.callStaticMethod("com.wanmei.mini.condor.GameApp", "setPlayerData", curUserData, nil)
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lnvo" then
        if self.goodid then
            local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
            goodname = record.productstr    
            if not string.find(record.roofid, "lnvo") then
                return
            end
        end
    end

	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lemn" then
		local record = nil
		if self.goodid then
			record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
		else
			print("____error no self.goodid")
		end

		if record and record.id ~= -1 and record.productstr then
			LogInfo("____self.goodname: " .. self.goodname .. " productstr: " .. record.productstr)
			goodname = record.productstr
		end
	end

	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
		goodname = self.extra
	end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
        require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.uc.UcPlatform", "purchase2", {json}, nil)
        return
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        require "luaj"
        luaj.callStaticMethod("com.efun.ensd.ucube.PlatformTwApp01", "purchase2", {json}, nil)
        return
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
        require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.tw360.PlatformTw360","purchase2",{json}, nil)
        return
    end

	SDXL.ChannelManager:StartBuyYuanbao(self.billid, goodname, self.goodid, self.goodnum, self.price, self.serverid)
end

local sreqchargehistory = require "protocoldef.knight.gsp.yuanbao.sreqchargehistory"
function sreqchargehistory:process()
	LogInfo("enter sreqchargehistory process")
	require "ui.chargedialog"
	ChargeDialog.getInstance():SetHistoryPage(self.page, self.totalpage)
	ChargeDialog.getInstance():ResetAllHistory()
	for k,v in ipairs(self.historylist) do
		ChargeDialog.getInstance():AddHistory(k, v.sn, v.status, v.createtime, v.price)
	end
end

local srefreshchargestate = require "protocoldef.knight.gsp.yuanbao.srefreshchargestate"
function srefreshchargestate:process()
	LogInfo("enter srefreshchargestate process state :" .. self.state)
	require "ui.firstchargebtn"
	require "ui.chargedialog"

	FirstChargeBtn.getInstanceAndShow():RefreshByChargeState(self.state, self.flag)
	ChargeDialog.m_ChargeState = self.state
    ChargeDialog.m_ChargeFlag = self.flag
end

local scontinuecharge = require "protocoldef.knight.gsp.yuanbao.scontinuecharge"
function scontinuecharge:process()
  LogInfo("____scontinuecharge:process")
  local BinfenGiftBtn = require "ui.binfengift.binfengiftbtn"
  
  if self.status < 0 then
      BinfenGiftBtn.DestroyDialog()
      return
  end
  
  local btnBinfenGift = BinfenGiftBtn.getInstanceAndShow()
  if btnBinfenGift then
      btnBinfenGift:RefreshBaseStateInfo(self.status, self.serverid, self.chargeendtime, self.consumeendtime, self.limittimebuyendtime, self.daytaskendtime, self.accumulateendtime)
  end
end


local sopencontinuechargedlg = require "protocoldef.knight.gsp.yuanbao.sopencontinuechargedlg"
function sopencontinuechargedlg:process()
    LogInfo("____sopencontinuechargedlg:process")
    
    --for shop show1
    if self.flag == 2 then
      if self.page == 3 then
        require "ui.shop.shoplabel"
        local _instance = require "ui.shop.shoplabel".getInstance()
        _instance:SetLimitTimeBuyData(self.limittimeitems, self.endtime)
        _instance.Show(1,1)
      end
      return
    end
   
   --for shop show3
   if self.flag == 3 then
      if self.page == 3 then
        require "ui.shop.shoplabel"
        local _instance = require "ui.shop.shoplabel".getInstance()
        _instance:SetLimitTimeBuyData(self.limittimeitems, self.endtime)
        _instance.Show(1,3)
      end
      return
    end
    
    
    --binfensongli
    local btnBinfenGift = require "ui.binfengift.binfengiftbtn".getInstanceAndShow()

    if self.page == 1 then
        btnBinfenGift:SetChargeItems(self.items, self.curnum, self.endtime)
        return
    end

    if self.page == 2 then
        btnBinfenGift:SetConsumeItems(self.items, self.curnum, self.endtime)
        return
    end

    if self.page == 3 then
        btnBinfenGift:SetLimitTimeBuyItems(self.limittimeitems, self.curnum, self.endtime)
        return
    end
end

local srspserverid = require "protocoldef.knight.gsp.yuanbao.srspserverid"
function srspserverid:process()
    LogInfo("____srspserverid:process")
	require "ui.chargedialog"
    require "ui.facebookbuttondlg"
    if  FacebookButtonDlg.getInstanceNotCreate() and FacebookButtonDlg.getInstanceNotCreate():IsVisible() and self.flag == FacebookButtonDlg.s_flagFacebookReqServiceID then
        FacebookButtonDlg.getInstanceNotCreate():GetServerIdHandler(self.serverid)
        
    end
end

local svipitembuy = require "protocoldef.knight.gsp.yuanbao.svipitembuy"
function svipitembuy:process()
	require "ui.shop.shopdlg"
    LogInfo("____svipitembuy:process")
    
    local dlgShopDialog = ShopDlg.getInstanceNotCreate()
    if not dlgShopDialog then
        return
    end 
    if not dlgShopDialog:IsVisible() then
        return
    end

    dlgShopDialog:RefreshHasBuyNumVIPLimitSellItem(self.items)
    dlgShopDialog:RefreshVIPLimitSellItemsShow()
end

local sactiveachivelist = require "protocoldef.knight.gsp.yuanbao.sactiveachivelist"
function sactiveachivelist:process()
	local btnBinfenGift = require "ui.binfengift.binfengiftbtn".getInstanceAndShow()
	if self.page == 4 then
		btnBinfenGift:SetDailyTaskItem(self.achivelist, self.endday)
	elseif self.page == 5 then
		btnBinfenGift:SetAccumulateItem(self.achivelist, self.days, self.endday)
	end
end

local stakeawardfresh = require "protocoldef.knight.gsp.yuanbao.stakeawardfresh"
function stakeawardfresh:process()
	local dlgBinfenGift = require "ui.binfengift.binfengiftdlg".getInstanceAndShow()
	if self.page == 4 then
		dlgBinfenGift:DailyTaskBtnRefresh(self.key, self.flag)
	elseif self.page == 5 then
		dlgBinfenGift:AccumulateBtnRefresh(self.key, self.flag)
	end
end