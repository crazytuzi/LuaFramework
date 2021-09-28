local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local MiJingModel = require "Zeus.Model.MiJing"
local ServerTime = require "Zeus.Logic.ServerTime"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"

local self={}
local isShowEffect = false
local GetBox = ""
local GetYZML = ""
local GoToMijing = ""
local NotStart = ""
local NotStartTips = ""
local NextStart = ""
local TodayEnd = ""
local TodayStart = ""
local MJIntrduce = ""
local MJTitle = ""
local RewardTitle = ""
local GetRewardTitle = ""




local function InitUI()
	
	local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
	local UIName = {
		"btn_close",
		"lb_num",
		"btn_yes",
		"lb_opentime",
		"btn_help",
		"cvs_intrduce",
		"lb_location",
		"tb_intrduce",
		"btn_intrduce",
		"sp_list1",
		"sp_list2",
		"ib_icon1",
		"ib_icon2",
		"cvs_icon",
		"lb_num1",
		"rewardTitle",
		"getRewardTitle",
	}
	for i=1,#UIName do
		self[UIName[i]] = self.menu:GetComponent(UIName[i])
	end
	
	GetBox = Util.GetText(TextConfig.Type.FUBEN, "GetBox")
	GetYZML = Util.GetText(TextConfig.Type.FUBEN, "GetYZML")
	GoToMijing = Util.GetText(TextConfig.Type.FUBEN, "GoToMijing")
	NotStart = Util.GetText(TextConfig.Type.FUBEN, "NotStart")
	NotStartTips = Util.GetText(TextConfig.Type.FUBEN, "NotStartTips")
	NextStart = Util.GetText(TextConfig.Type.FUBEN, "NextStart")
	TodayEnd = Util.GetText(TextConfig.Type.FUBEN, "TodayEnd")
	TodayStart = Util.GetText(TextConfig.Type.FUBEN, "TodayStart")
	MJIntrduce = Util.GetText(TextConfig.Type.FUBEN, "MJIntrduce")
	MJTitle = Util.GetText(TextConfig.Type.FUBEN, "MJTitle")
	RewardTitle = Util.GetText(TextConfig.Type.FUBEN, "RewardTitle")
	GetRewardTitle = Util.GetText(TextConfig.Type.FUBEN, "GetRewardTitle")

	self.rewardTitle.Text = RewardTitle
	self.getRewardTitle.Text = GetRewardTitle
	
	self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end
end

local function UpdateRewards()
	local boxNumList={}
	local todayMlNum=0
	local todayMaxNum=0
	for k,v in pairs(self.InfoData.item_info) do
   			todayMlNum = v.s2c_today_ml
   			todayMaxNum = v.s2c_max_ml
    end
    
    local smallBox = self.InfoData.s2c_today_lv1
	local middleBox = self.InfoData.s2c_today_lv2
	local largeBox = self.InfoData.s2c_today_lv3
	local todayBoxNum = smallBox + middleBox + largeBox
	self.lb_num1.Text = GetBox..todayBoxNum.."/"..self.InfoData.s2c_max_num
	 if todayBoxNum >= self.InfoData.s2c_max_num then 
        self.lb_num1.FontColorRGBA = 0xff0000ff   
    else
        self.lb_num1.FontColorRGBA = 0x00ff00ff  
    end
  
    self.lb_num.Text = GetYZML..todayMlNum.."/"..todayMaxNum
	 if todayMlNum >= todayMaxNum then 
        self.lb_num.FontColorRGBA = 0xff0000ff   
    else
        self.lb_num.FontColorRGBA = 0x00ff00ff  
    end
    
	table.insert(boxNumList,self.InfoData.s2c_today_lv1)
    table.insert(boxNumList,self.InfoData.s2c_today_lv2)
    table.insert(boxNumList,self.InfoData.s2c_today_lv3)
    table.insert(boxNumList,todayMlNum)

	
	local listData = GlobalHooks.DB.Find("Parameters", {ParamName = "Mysterious.RewardShow"})[1].ParamValue
	local itemList = string.split(listData,",")
	self.sp_list1:Initialize(self.ib_icon1.Width+10, self.ib_icon1.Height, 1, #itemList, self.ib_icon1,
      function(x, y, cell)
          local index = x + 1
          local code = itemList[index]
          local it = GlobalHooks.DB.Find("Items",code)
          cell.Enable = true
    	  cell.EnableChildren = true
          local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor)
          Util.NormalItemShowTouchClick(itshow,code,false)
      end,
      function()

      end
  )
	
	local getListData = GlobalHooks.DB.Find("Parameters", {ParamName = "Mysterious.GetRewardNum"})[1].ParamValue
	local getItemList = string.split(getListData,",")
		self.sp_list2:Initialize(self.cvs_icon.Width+10, self.cvs_icon.Height, 1, #getItemList, self.cvs_icon, 
      function(x, y, cell)
          local index = x + 1
          local code = getItemList[index]
          local it = GlobalHooks.DB.Find("Items",code)
          local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor, boxNumList[index],true)
          Util.NormalItemShowTouchClick(itshow,code,false)
      end,
      function()

      end
  )
end

local function UpdateMJTimeStr(label, timeSeq)
    
    local currTime = ServerTime.GetServerUnixTime()
    local nowTime = GameUtil.NormalizeTimpstamp(currTime)
    local nowCount = nowTime.Hour*3600+nowTime.Minute*60+nowTime.Second

    
    if self.flagTimeCount then
        local tmp = self.flagTimeCount - nowCount
        if tmp < 10 and tmp > 0 then
            return
        end
    end
    self.flagTimeCount = nowCount
    	 
    local rolelv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
	local openLvData = GlobalHooks.DB.Find('OpenLv',{ID = 70})[1]
	if openLvData == nil or not openLvData then end

    	for j=1,#timeSeq-1 do
	        local time1 = string.split(timeSeq[j], '-')
	        local endHour = tonumber(string.split(time1[2], ':')[1])
	        local endMinute = tonumber(string.split(time1[2], ':')[2])
	        local endTimeCount = endHour*3600+endMinute*60

	        local time2 = string.split(timeSeq[j+1],'-')
	        local nextstartHour = tonumber(string.split(time2[1], ':')[1])
	        local nextstartMinute = tonumber(string.split(time2[1], ':')[2])
	        local nextstartTimeCount = nextstartHour*3600+nextstartMinute*60
	        
	        if (nowCount >= endTimeCount and nowCount <= nextstartTimeCount) then
	        	
	            local cutDown = nextstartTimeCount - nowCount
	            if cutDown <= 0 then
	            	self.lb_opentime.Visible = false
					self.btn_yes.Text = GoToMijing
					self.btn_yes.IsGray = false
					Util.showUIEffect(self.btn_yes,55)
					isShowEffect = true
					self.btn_yes.TouchClick = function()
						if rolelv < openLvData.OpenLv then
							GameAlertManager.Instance:ShowNotify(openLvData.Tips)
						else
							MiJingModel.EnterLllsion2Request()
						end
					end
				else
					self.btn_yes.Text = NotStart	
					self.btn_yes.IsGray = true
					self.lb_opentime.Visible = true
					if isShowEffect == true then
						Util.clearUIEffect(self.btn_yes,55)
						isShowEffect = false
					end
					self.btn_yes.TouchClick = function()
						GameAlertManager.Instance:ShowNotify(NotStartTips)
					end
		            local h = math.floor(cutDown/3600)
		            local m = math.floor(cutDown/60)-h*60
		            local s = cutDown-h*3600-m*60
		            if h == 0 then
		                h = ""
		            elseif h < 10 then
		                h = "0"..h..":"
		            else
		                h = h..":"
		            end
		            if m == 0 then
		                m = "00"..":"
		            elseif m < 10 then
		                m = "0"..m..":"
		            else
		                m = m..":"
		            end
		            if s == 0 then
		                s = "00"
		            elseif s < 10 then
		                s = "0"..s
		            end
		            label.Text = NextStart..h..m..s
		            return
		         end
	        end
    end

    if not isShowEffect then
		self.lb_opentime.Visible = false
		self.btn_yes.Text = GoToMijing
		self.btn_yes.IsGray = false
		Util.showUIEffect(self.btn_yes,55)
		isShowEffect = true
		self.btn_yes.TouchClick = function()
			if rolelv < openLvData.OpenLv then
				GameAlertManager.Instance:ShowNotify(openLvData.Tips)
			else
				MiJingModel.EnterLllsion2Request()
			end
		end
	end
    label.Text = ""
end

local function  RequestData()
	local data = GlobalHooks.DB.Find('Schedule',15)
    local timeList = string.split(data.PeriodInCalendar,";")
    local openTime = string.split(timeList[1], "-")[1]
    local startTime =  tonumber(string.split(openTime,":")[1])*3600+tonumber(string.split(openTime,":")[2])*60
    local endTimeStr = string.split(timeList[#timeList],"-")[2]
    local endTime = tonumber(string.split(endTimeStr,":")[1])*3600+tonumber(string.split(endTimeStr,":")[2])*60
	local currTime = math.floor(ServerTime.GetServerUnixTime())
	local hour = tonumber(os.date("%H",currTime))
    local min = tonumber(os.date("%M",currTime))
    local sec = tonumber(os.date("%S",currTime))
    local _currSeconds = hour*3600+min*60+sec

	if _currSeconds >= startTime and _currSeconds < endTime then
		 AddUpdateEvent("Event.MiJing.UpdateTime", function(deltatime)
		                UpdateMJTimeStr(self.lb_opentime, timeList)
		            end)
	elseif _currSeconds >= endTime then
		self.btn_yes.Text = NotStart	
		self.btn_yes.IsGray = true
		self.lb_opentime.Visible = true
		self.lb_opentime.Text=TodayEnd
		Util.clearUIEffect(self.btn_yes,55)
		isShowEffect = false
		self.btn_yes.TouchClick = function()
			GameAlertManager.Instance:ShowNotify(NotStartTips)
		end
	else
		self.btn_yes.Text = NotStart	
		self.btn_yes.IsGray = true
		self.lb_opentime.Visible = true
		self.lb_opentime.Text=TodayStart
		Util.clearUIEffect(self.btn_yes,55)
		isShowEffect = false
		self.btn_yes.TouchClick = function()
			GameAlertManager.Instance:ShowNotify(NotStartTips)
		end
	end
end

local function IntrductInfo()
	self.btn_help.TouchClick = function()
		self.lb_location.Text = MJTitle
		self.lb_location.FontColorRGBA = 0xff00a0ff
		local data = GlobalHooks.DB.Find('Schedule',15)
		self.tb_intrduce.Text = string.format(MJIntrduce,"\n","\n","\n","\n","\n",data.PeriodInCalendar)
		if self.cvs_intrduce.Visible == false then
			self.cvs_intrduce.Visible = true
		end
	end
	self.btn_intrduce.TouchClick = function()
		if self.cvs_intrduce.Visible == true then
			self.cvs_intrduce.Visible = false
		end
	end	
end

local function OnEnter()
	self.InfoData = {}
	MiJingModel.getLllsion2InfoRequest(function (data)
		self.InfoData = data
		UpdateRewards()
		IntrductInfo()
		RequestData()
	end)
end

local function OnExit()
	 RemoveUpdateEvent("Event.MiJing.UpdateTime", true)
	 isShowEffect = false
	 self.InfoData = nil
end



local function  Init( params )
	self.menu = LuaMenuU.Create("xmds_ui/hud/mijing.gui.xml", GlobalHooks.UITAG.GameUIMiJing)
	self.menu.Enable = true
	self.menu.mRoot.Enable = true
	InitUI()
	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
	return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return { Create = Create }
