local CAttrCardLinkView = class("CAttrCardLinkView", CViewBase)

function CAttrCardLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrCardLinkView.prefab", cb)
	self.m_ExtendClose = "Black"
    self.m_NeedGoldCoin = 580  --非免费改名需要元宝数量
	self.m_RenameMaxGrade = 50 --超过此等级需要元宝
	self.m_RenameMinGrade = 10 --低于此等级无法改名
	self.m_LikeNeedGrade = 30  --点赞需要等级
	self.m_ChannelList = { define.Channel.Current,
	  					   define.Channel.Org,	 	  
	  					   define.Channel.Team,
	  					   define.Channel.World,
						 }	
end

function CAttrCardLinkView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_LvLabel = self:NewUI(2, CLabel)	
	self.m_RenameBtn = self:NewUI(4, CButton)
	self.m_InfoGrid = self:NewUI(5, CGrid)    
	self.m_AddFriendBtn = self:NewUI(6, CButton)
	self.m_Pid = self:NewUI(7, CLabel)	
	self.m_ActorTexture = self:NewUI(8, CActorTexture)
    self.m_Moods = self:NewUI(9,CLabel)
    self.m_GiveBtn = self:NewUI(10,CButton)
    self.m_PraiseBtn = self:NewUI(11,CButton)
    self.m_FindBtn = self:NewUI(12,CButton)
    self.m_SendCardBtn = self:NewUI(13,CButton)
	self.m_SchoolPic = self:NewUI(14,CSprite)
	self.m_ChannelBtnGrid = self:NewUI(15,CGrid)
	self.m_ChannelBtns = self:NewUI(16,CBox)
	self.m_CloseChannelBtns = self:NewUI(17,CButton,false,false)
	self.m_ChannelBtns:SetActive(false)
	local function InitAttr(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
		oBox.m_AttrLabel:SetText("暂无")
		return oBox
	end
	self.m_InfoGrid:InitChild(InitAttr)
	self.m_ShowPosBtn = self.m_InfoGrid:GetChild(6):NewUI(3,CButton)
	local function InitChannelBtns(obj, idx)
		local btn = CButton.New(obj)
		btn:AddUIEvent("click",callback(self,"SendMSg",idx))
		return btn
	end
	self.m_ChannelBtnGrid:InitChild(InitChannelBtns)
	self:BindButtonEvent()
end

function CAttrCardLinkView.BindButtonEvent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddFriendBtn:AddUIEvent("click", callback(self, "OnAddFriend"))
	self.m_RenameBtn:AddUIEvent("click", callback(self, "OpenRenameWindow"))
    self.m_GiveBtn:AddUIEvent("click",callback(self,"OnGiveGift"))
    self.m_SendCardBtn:AddUIEvent("click",callback(self,"SendCard"))
    self.m_PraiseBtn:AddUIEvent("click",callback(self,"OnPraise"))
    self.m_FindBtn:AddUIEvent("click",callback(self,"OnFind"))
	self.m_ShowPosBtn:AddUIEvent("click",callback(self,"OnShowPos"))
	self.m_CloseChannelBtns:AddUIEvent("click",callback(self,"OnCloseChannelBtns"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CAttrCardLinkView.OnCtrlEvent(self, oCtrl)	
	--刷新当前UI
	if oCtrl.m_EventID == define.Attr.Event.Change and self.m_CardPid == g_AttrCtrl.pid then	
		self:SetSelfCardInfo()
	end	
end
 
function CAttrCardLinkView.SetSelfCardInfo(self)
    self.m_GiveBtn:SetActive(false)
    self.m_PraiseBtn:SetSpriteName("h7_chakan_hui")
    self.m_AddFriendBtn:SetActive(false)
    self.m_SendCardBtn:SetActive(true)
	self.m_RenameBtn:SetActive(true)
    self:SetCardInfo(nil)
end

function CAttrCardLinkView.SetCardLinkInfo(self,data)
    self.m_RenameBtn:SetActive(false)
    self.m_GiveBtn:SetActive(false)
    self.m_PraiseBtn:SetSpriteName("h7_dianzan")
    self.m_AddFriendBtn:SetActive(true)
    self.m_SendCardBtn:SetActive(false)
    self.m_InfoGrid:GetChild(6):NewUI(3,CButton):SetActive(false)
    self:SetCardInfo(data)
end

function CAttrCardLinkView.SetCardInfo(self,data)
    local attr = g_AttrCtrl
    if data ~= nil then 
        attr = data
    end 
	self.m_CardPid = attr.pid
	self.m_IsShowPos = attr.position_hide
	self.m_MoodsAmount = attr.upvote_amount
	self.m_SchoolPic:SetSpriteName(tostring(attr.school))
    self.m_NameLabel:SetText(attr.name)
	self.m_LvLabel:SetText("等级: "..attr.grade)
	self.m_Pid:SetText("ID: "..attr.pid)
	self.m_Moods:SetText(attr.upvote_amount)
	local pos = self.m_InfoGrid:GetChild(6).m_AttrLabel
	if self.m_IsShowPos == 1 then
		pos:SetText(attr.position)
		self.m_ShowPosBtn:SetSpriteName("h7_kejiananniu")
	else
		pos:SetText("隐藏")
		self.m_ShowPosBtn:SetSpriteName("h7_bukejiananniu")
	end	
end


function CAttrCardLinkView.SendMSg(self,idx)
	self.m_ChannelBtns:SetActive(false)
	local channel = self.m_ChannelList[idx]
	if channel == define.Channel.Org then 
		--判断是否有公会
		g_NotifyCtrl:FloatMsg("您还没有公会!")
		return
	end 
	if channel == define.Channel.Team then 
		--判断是否有队伍
		if not g_TeamCtrl:IsJoinTeam() then 
			g_NotifyCtrl:FloatMsg("您还没有队伍!")
			return
		end 
	end 
	CChatMainView:ShowView(function(oView)
		oView:SwitchChannel(channel)
		local applyLink = LinkTools.GenerateAttrCardLink("名片-"..g_AttrCtrl.name,g_AttrCtrl.pid)
		local msg = applyLink
		oView.m_ChatPart:AppendText(msg)
		self:OnClose()
	end)
end

function CAttrCardLinkView.SendCard(self)
	self.m_ChannelBtns:SetActive(not self.m_ChannelBtns:GetActive())
end

function CAttrCardLinkView.OnCloseChannelBtns(self)
	self.m_ChannelBtns:SetActive(false)
end

function CAttrCardLinkView.OpenRenameWindow(self)
	if g_AttrCtrl.grade < self.m_RenameMinGrade then 
		g_NotifyCtrl:FloatMsg("你的等级＜10级无法改名!")
		return
	end 
	local des = "10≤角色等级≤50，第一次改名免费哦!\n                            2-5个文字"
	if g_AttrCtrl.grade > self.m_RenameMaxGrade or g_AttrCtrl.rename > 0 then 
		des = "本次改名需要消耗"..self.m_NeedGoldCoin.."元宝\n                           2-5个文字"
	end 
	local windowInputInfo = {
		des				= des,
		title			= "改名",
		inputLimit		= 10,
		cancelCallback	= function ()
			
		end,
		defaultCallback = nil,
		okCallback		= function (input)
		 	self:OkRename(input)
		end,
		defaultStr		= "确认",
		okStr			= "确认",
		cancelStr		= "取消",
		thirdStr		= "",
		isclose         = false,
		defaultText		= "请输入名称"
	}
    g_WindowTipCtrl:SetWindowInput(windowInputInfo, function(self, oView)
   		self.m_RenameView = oView
    end)

end

function CAttrCardLinkView.OkRename(self,input)
	local g_AttrCtrl = g_AttrCtrl
	if input:GetInputLength() < 4 or input:GetInputLength() > 10 then 
		g_NotifyCtrl:FloatMsg("请输入2-5个文字!")
		return
	end 
	local name = input:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
		return
	end

	if (g_AttrCtrl.grade > self.m_RenameMaxGrade or g_AttrCtrl.rename > 0) and g_AttrCtrl.goldcoin < self.m_NeedGoldCoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
		return
	end 
	self.m_RenameView:OnClose()
	netplayer.C2GSRename(name)	
end

function CAttrCardLinkView.OnGiveGift(self)
    print("赠送礼物")
end

function CAttrCardLinkView.OnAddFriend(self)
	if self.m_CardPid == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("不能添加自己为好友!")
		return
	end
	if g_FriendCtrl:IsMyFriend(self.m_CardPid) then
		g_NotifyCtrl:FloatMsg("对方已经是您的好友了!")
		return
	end
	g_FriendCtrl:ApplyFriend(self.m_CardPid)
end

--是否显示位置
function CAttrCardLinkView.OnShowPos(self)
	local hide = self.m_IsShowPos == 0 and 1 or 0
	netplayer.C2GSHidePosition(hide)
end

--点赞
function CAttrCardLinkView.OnPraise(self)
	if g_AttrCtrl.pid == self.m_CardPid then 
		g_NotifyCtrl:FloatMsg("不能给自己点赞哦!")
		return
	end 
	if g_AttrCtrl.grade < self.m_LikeNeedGrade then 
		g_NotifyCtrl:FloatMsg("点赞需要等级达到"..self.m_LikeNeedGrade.."级!")
		return
	end 
	if self.m_CardPid then 	
		netplayer.C2GSUpvotePlayer(self.m_CardPid)
	end
end

--打开点赞列表
function CAttrCardLinkView.OnFind(self)
	if self.m_MoodsAmount <= 0 then 
		g_NotifyCtrl:FloatMsg("当前还没有获得点赞人气哦!")
		return
	end 
	netplayer.C2GSPlayerUpvoteInfo(self.m_CardPid)
end

--添加点赞人数
function CAttrCardLinkView.MoodsAdd(self)
	self.m_MoodsAmount = self.m_MoodsAmount+1
	self.m_Moods:SetText(self.m_MoodsAmount)
end

return CAttrCardLinkView