-- @author hze
-- @date #18/02/27#
-- 签到抽奖活动、传递花语活动、直购7日礼包活动

SignDrawManager = SignDrawManager or BaseClass(BaseManager)

function SignDrawManager:__init()
    if SignDrawManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    SignDrawManager.Instance = self

    self.model = SignDrawModel.New()

    self:InitHandler()

    self.friend_list = {}

    self.send_flower_id = 1 --当前传递的花id

    self.OnUpdateSignStatus = EventLib.New()
    self.OnUpdateQuestList = EventLib.New()
    self.OnUpdateRewardList = EventLib.New()
    self.OnUpdateDraw = EventLib.New()


    self.OnUpdateFlowerListEvent = EventLib.New()

    self.OnUpdatePassBlessFlowerRed = EventLib.New()

    self.OnUpdateDirectPackage = EventLib.New()
end

function SignDrawManager:__delete()
	if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.OnUpdateQuestList ~= nil then
        self.OnUpdateQuestList:DeleteMe()
        self.OnUpdateQuestList = nil
    end

    if self.OnUpdateSignStatus ~= nil then
        self.OnUpdateSignStatus:DeleteMe()
        self.OnUpdateSignStatus = nil
    end

    if self.OnUpdateRewardList ~= nil then
        self.OnUpdateRewardList:DeleteMe()
        self.OnUpdateRewardList = nil
    end

    if self.OnUpdateDraw ~= nil then
        self.OnUpdateDraw:DeleteMe()
        self.OnUpdateDraw = nil
    end

    if self.OnUpdateDirectPackage ~= nil then
        self.OnUpdateDirectPackage:DeleteMe()
        self.OnUpdateDirectPackage = nil
    end

end

function SignDrawManager:RequestInitData()
    self:Send20439()
    self:Send20451()
    self:Send20481()
    self:Send20479()
end

function SignDrawManager:InitHandler()
	self:AddNetHandler(20436, self.On20436)
    self:AddNetHandler(20437, self.On20437)
    self:AddNetHandler(20438, self.On20438)
    self:AddNetHandler(20439, self.On20439)
    self:AddNetHandler(20451, self.On20451)
    self:AddNetHandler(20452, self.On20452)
    self:AddNetHandler(20453, self.On20453)
    self:AddNetHandler(20454, self.On20454)
    self:AddNetHandler(20455, self.On20455)
    self:AddNetHandler(20479, self.On20479)
    self:AddNetHandler(20480, self.On20480)
    self:AddNetHandler(20481, self.On20481)
end

function SignDrawManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


function SignDrawManager:Send20436()
   --print("发送20436协议")
   self:Send(20436,{})
end

function SignDrawManager:On20436(data)
	--BaseUtils.dump(data,TI18N("<color=#FF0000>接收20436</color>"))
	self.OnUpdateSignStatus:Fire(data)
end



function SignDrawManager:Send20437()
	 --print("发送20437协议")
   self:Send(20437,{})
end

function SignDrawManager:On20437(data)
	-- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20437</color>"))
    if data.result ~= nil then
        if self.model.markHide then
            NoticeManager.Instance:FloatTipsByString(NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#b031d5'>[%sx%d]</color>",TI18N("获得"),DataItem.data_get[data.result[1].base_id].name,data.result[1].num*data.result[1].base_num)))
            self.model.markHide = false
        end
	   self.OnUpdateDraw:Fire(data)
    end
end


function SignDrawManager:Send20438()
	--print("发送20438协议")
   self:Send(20438,{})
end

function SignDrawManager:On20438(data)
	--BaseUtils.dump(data,TI18N("<color=#FF0000>接收20438</color>"))
	self.model.rewardData = data
	self.OnUpdateRewardList:Fire(data)
end




function SignDrawManager:Send20439()
	--print("发送20439协议")
	self:Send(20439,{})
end

function SignDrawManager:On20439(data)
	--BaseUtils.dump(data,TI18N("<color=#FF0000>接收20439</color>"))
    if data.quest ~= nil then
        self.model.questList = data.quest
    end

    if data.sign[1] ~= nil then
        self.model.sign = data.sign[1] or {}
	end
    self.OnUpdateQuestList:Fire()
end


--请求花数据
function SignDrawManager:Send20451()
    -- print("发送20451协议")
    self:Send(20451,{})
end

function SignDrawManager:On20451(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20451</color>"))
    self.model.flower_list = data

    self.OnUpdateFlowerListEvent:Fire()
    self.OnUpdatePassBlessFlowerRed:Fire()
end


function SignDrawManager:Send20452(_type, _id)
    -- print("发送20452协议")
    self:Send(20452,{reward_type = _type, id = _id})
end

function SignDrawManager:On20452(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20452</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self:Send20451()
    end
end

--传递花给某个好友
function SignDrawManager:Send20453(_flower_id, _id, _platform, _zone_id)
    self:Send(20453,{flower_id = _flower_id, id = _id, platform = _platform, zone_id = _zone_id})
end

function SignDrawManager:On20453(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20453</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self:Send20451()
    end
end



function SignDrawManager:On20454(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20454</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    --心形界面
    if data.flag == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.passblesssubwindow, {data.name, data.flower_id, data.min})
    else
    --主界面
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.passblesswindow,{campId = 1062})
    end
    self:Send20451()
end

--请求可传递好友列表
function SignDrawManager:Send20455(flower_id)
    -- print("发送20455协议")
    self:Send(20455,{flower_id = flower_id})
    self.send_flower_id = flower_id
end

function SignDrawManager:On20455(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20455</color>"))
    self.friend_list = BaseUtils.copytab(data.role)


    local callBack = function(dat)
            for k,v in pairs(dat) do
                --回调确认传递好友
                SignDrawManager.Instance:Send20453(self.send_flower_id, v.id, v.platform, v.zone_id)

                local sendData = string.format(TI18N("亲爱的<color='#249015'>%s</color>,我给你送了一朵<color='#0780D8'>%s</color>哟，快去查看吧！{panel_2, 14003, 1, 点此查看, 0, 1062}"),v.name,DataCampPassFlowerLanguage.data_get_flower_info[self.send_flower_id].name)
                FriendManager.Instance:SendMsg(v.id,v.platform,v.zone_id,sendData)
            end
        end
    --打开好友选择界面
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 5 })
end


--直购7日礼包
function SignDrawManager:Send20479()
    print("发送20479协议")
    self:Send(20479,{})
end

function SignDrawManager:On20479(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20479</color>"))
    if data ~= nil then 
        self.model.data20479 = data.reward_info
        self.model.value = data.value
    end
    self.OnUpdateDirectPackage:Fire()
end

--领取直购7日礼包
function SignDrawManager:Send20480(id)
    self:Send(20480,{id = id})
end

function SignDrawManager:On20480(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--直购7日礼包可领取状态
function SignDrawManager:Send20481()
    self:Send(20481,{})
end

--直购7日礼包购买时间
function SignDrawManager:On20481(data)
    self.model.buy_time = data.buy_time
end