local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local SoloAPI = require "Zeus.Model.Solo"

local self = {}
local function SwitchPage(sender)
    if sender == self.tbt_reward1 then
        self.cvs_reward1.Visible = true
        self.cvs_reward2.Visible = false
    else
        self.cvs_reward1.Visible = false
        self.cvs_reward2.Visible = true
    end
end

local function FillIcon(node,rerard)
    local tmp = string.split(rerard,':')
    local code = tmp[1]
    local num = tmp[2]

    print("code = " .. code)
    local detail = ItemModel.GetItemDetailByCode(code)
    if detail== nil then
        return
    end
    local itshow = Util.ShowItemShow(node,detail.static.Icon,detail.static.Qcolor,num)
    itshow.EnableTouch = true
    itshow.TouchClick = function (sender)
        EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
    end
end

local iconList = {
    "#dynamic_n/arena/arena.xml|arena|2",
    "#dynamic_n/arena/arena.xml|arena|1",
    "#dynamic_n/arena/arena.xml|arena|0",
    "#dynamic_n/arena/arena.xml|arena|3",
}

local boxList = {
    "#static_n/func/solo.xml|solo|7",
    "dynamic_n/chest/baiyin.png",
    "dynamic_n/chest/baiyinkai.png",
}

local function InitList()
    local eles1 = self.rankdata
    self.rankStatus = {}
    if self.rewardData.s2c_rankRewards then
        for _,v in ipairs(self.rewardData.s2c_rankRewards) do
            self.rankStatus[v.rankId] = v.status
        end
    end

    local function UpdateGradeRewardItem(gx,gy,node)
        node.Visible = true
        local data = eles1[gy+1]
        local items = string.split(data.RankReward,';')
        local lb_rankname = node:FindChildByEditName('lb_rankname',false)
        local lb_num = node:FindChildByEditName('lb_num',false)
        local btn_receive = node:FindChildByEditName('btn_receive',false)
        local ib_not = node:FindChildByEditName('ib_not',false)
        local ib_already = node:FindChildByEditName('ib_already',false)

        
        ib_not.Visible = true
        ib_already.Visible = false

        lb_rankname.Text = data.RankName
        lb_rankname.FontColor = GameUtil.RGB2Color(tonumber(data.TextColour, 16))
        lb_num.Text = data.RankScore
        
        for i=1,3 do            
            local cvs_icon = node:FindChildByEditName('cvs_icon'..i,false)
            local item = items[i]
            cvs_icon.Visible = item ~= nil
            if item then
                FillIcon(cvs_icon,item)
            end
        end

        local s = self.rankStatus[data.ID]
        local refrashStatus = function (status)
            
            ib_not.Visible = false
            ib_already.Visible = false
            btn_receive.Visible = false
            
            if status == nil or status == 0 then
                ib_not.Visible = true
            elseif status == 2 then
                ib_already.Visible = true
            else
                btn_receive.Visible = true
            end
        end
        refrashStatus(s)

        btn_receive.TouchClick = function(sender)
            SoloAPI.requestRankReward(data.ID, function ()
                s = 2
                refrashStatus(s)
                self.rankStatus[data.ID] = 2
                
                local  reward = {}
                for i=1,3 do 
                    local tmp = string.split(items[i],':')
                    local code = tmp[1]
                    local num = tmp[2]
                    local detail = ItemModel.GetItemDetailByCode(code)
                    reward[detail.static.Name .. "(".. code .. ")"] = num
                end
                local duanweireward = Util.GetText(TextConfig.Type.SOLO, "duanweireward")
                Util.SendBIData("soloReward","",duanweireward,"","",reward,"")
                
            end)
        end
    end
    
    local s = self.cvs_single1.Size2D
    self.sp_show1:Initialize(s.x,s.y,#eles1,1,self.cvs_single1,UpdateGradeRewardItem,function() end)    

    if self.rewardData.s2c_dailyRewards and self.rewardData.s2c_dailyRewards[1] ~= nil then
        MenuBaseU.SetEnableUENode(self.tb_view,true,false)
        self.tb_view:DecodeAndUnderlineLink(self.tb_view.Text)
        self.tb_view.LinkClick = function (link_str)
            local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloRewardBox,-1,"view")   
            print("self.rewardData.s2c_dailyRewards[1] =" .. PrintTable(self.rewardData.s2c_dailyRewards[1]))
            
            local tmp = string.split(self.curRankChest,';')
            obj:setViewRewardData(tmp)
        end
    else
        self.tb_view.Visible = false
    end

    local isShowCount = false
    for i=1,2 do
        local boxdata = nil
        if self.rewardData.s2c_dailyRewards and i<= #self.rewardData.s2c_dailyRewards then
            boxdata = self.rewardData.s2c_dailyRewards[i]
        end

        self["cvs_box" .. i].Enable = false
        self["ib_box" .. i].Enable = true
        self["cvs_box" ..i .. "_openef"].Enable = false
        
        
        
        if boxdata ~= nil then
            
            print("boxdata1 ---" ..boxdata.status .. "  " .. self["ib_box" .. i].X)
            self["ib_box" .. i].Visible = true
            self["ib_shad" .. i].Visible = false
            Util.HZSetImage(self["ib_box" .. i], boxList[boxdata.status + 1], false, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
            if boxdata.status == 1 then
                self["cvs_box" .. i].Enable = true
                Util.showUIEffect(self["cvs_box" ..i .. "_openef"],49)
            end

            if boxdata.status == 0 then
                isShowCount = true
            end
        else
            print("boxdata2")
            self["ib_box" .. i].Visible = false
            self["ib_shad" .. i].Visible = true
            
        end

        self["cvs_box" .. i].TouchClick = function ()
            SoloAPI.requestDailyReward(i,function(data)
                boxdata.status = 2
                
                Util.clearUIEffect(self["cvs_box" ..i .. "_openef"],49)
                Util.HZSetImage(self["ib_box" .. i], boxList[3], true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
                self["cvs_box" .. i].Enable = false
                local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloRewardBox,-1,"get")
                obj:setRewardData(data.s2c_dailyRewardItems)

                
                local  reward = {}
                for _,v in ipairs(data.s2c_dailyRewardItems) do
                    local detail = ItemModel.GetItemDetailByCode(v.itemCode)
                    reward[detail.static.Name .. "(".. v.itemCode .. ")"] = v.itemNum
                end
                local dailyboxreward = Util.GetText(TextConfig.Type.SOLO, "dailyboxreward")
                Util.SendBIData("soloReward","",dailyboxreward,"","",reward,"")
                
            end)
        end
    end

    self.lb_title2.Visible = not isShowCount
    self.lb_title.Visible = isShowCount
    self.gg_box.Visible = isShowCount
    self.lb_speed.Visible = isShowCount
    self.ib_ggbg.Visible = isShowCount
    self.gg_box:SetGaugeMinMax(0, 5)
    self.gg_box.Value = self.rewardData.s2c_dailyBattleTimes

    self.lb_speed.Text = self.rewardData.s2c_dailyBattleTimes .. "/5"
end

local function setSeasonReward()
    local eles2 = GlobalHooks.DB.Find('SoloRankSeasonReward',{})
    local ranktext = Util.GetText(TextConfig.Type.SOLO,'oneRank')
    local function UpdateRankRewardItem(gx,gy,node)
        node.Visible = true
        local data = eles2[gy+1]
        local items = string.split(data.RankReward,';')
        local ib_rank = node:FindChildByEditName('ib_rank',false)
        local lb_ranknum = node:FindChildByEditName('lb_ranknum',false)

        if ib_rank~= nil then
            local iconIndex = gy+1 > 4 and 4 or gy+1
            Util.HZSetImage(ib_rank, iconList[iconIndex], true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        end

        if data.StartRank == data.StopRank then
            lb_ranknum.Text = Util.CSharpStringformat(ranktext,data.StartRank)
        else
            local indexStr = data.StartRank..'-'..data.StopRank
            lb_ranknum.Text = Util.CSharpStringformat(ranktext,indexStr)
        end

        
        for i=1,4 do            
            local cvs_icon = node:FindChildByEditName('cvs_icon'..i,false)
            local item = items[i]
            cvs_icon.Visible = item ~= nil
            if item then
                FillIcon(cvs_icon,item)
            end
        end
    end

    local s = self.cvs_single2.Size2D
    self.sp_show2:Initialize(s.x,s.y,#eles2,1,self.cvs_single2,UpdateRankRewardItem,function() end)
end

function _M:setMyData(data)
    self.myData = data

    
    
    
    
end

function _M:OnEnter()
	self.cvs_reward.Visible = false

    local  function setMyInfo()
        self.lb_mequalifications.Text = self.myData.score
        
        self.lb_merank2.Text = self.myData.rank
        
        local curRank = nil
        for _,v in ipairs(self.rankdata) do
            if self.myData.score < v.RankScore then
                break
            end
            curRank = v
        end
            
        self.lb_merank1.Text = curRank.RankName
        self.lb_merank1.FontColor = GameUtil.RGB2Color(tonumber(curRank.TextColour, 16))
        self.curRankChest = curRank.ChestPreview
        SoloAPI.requestRewardInfo(function(data)
            self.rewardData = data
            InitList()
            self.cvs_reward.Visible  = true
        end)
    end

    local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISolo)
    self.myData = lua_obj:getMyInfo()
    if self.myData == nil then
        setMyInfo()
    else
        SoloAPI.requestSoloInfo(function(myInfo, soloMessages)
            self.myData = myInfo
            setMyInfo()
        end)
    end

end

function _M:OnExit()

end

local ui_names = 
{
    {name = 'cvs_reward'},
    {name = 'tbt_reward1'},
    {name = 'tbt_reward2'},
    {name = 'cvs_reward1'},
    {name = 'cvs_reward2'},
    {name = 'lb_mequalifications'},
    {name = 'sp_show1'},
    {name = 'sp_show2'},
    {name = 'cvs_single1'},
    {name = 'cvs_single2'},
    {name = 'lb_merank1'},
    {name = 'lb_merank2'},
    {name = 'lb_mequalifications'},
    {name = 'tb_view'},
    {name = 'lb_merank1'},
    {name = 'lb_merank2'},
    {name = 'lb_mequalifications'},
    {name = 'ib_box1'},
    {name = 'ib_box2'},
    {name = 'cvs_box1'},
    {name = 'cvs_box2'},
    {name = 'gg_box'},
    {name = 'lb_speed'},
    {name = 'ib_shad1'},
    {name = 'ib_shad2'},
    {name = 'lb_title'},
    {name = 'lb_title2'},
    {name = 'ib_ggbg'},
    {name = 'cvs_box1_openef'},
    {name = 'cvs_box2_openef'}
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
            	end
        	end
    	end
	end
end

local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/solo/solo_reward.gui.xml')
    initControls(self.menu,ui_names,self)

    self.cvs_single1.Visible = false
    self.cvs_single2.Visible = false
    self.rankdata = GlobalHooks.DB.Find('SoloRank',{})

    Util.InitMultiToggleButton(function (sender)
        SwitchPage(sender)
    end,self.tbt_reward1,{self.tbt_reward1,self.tbt_reward2})

    self.cvs_reward.Visible = false
    setSeasonReward()
    return self.menu
end

function _M.Create()

    setmetatable(self,_M)
    local node = InitComponent(self)
    return self,node
end

return _M
