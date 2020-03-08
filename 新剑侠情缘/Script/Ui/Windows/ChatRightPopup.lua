local tbUi = Ui:CreateClass("ChatRightPopup");

function tbUi:OnOpen(szPlayerName, nFromY)
	nFromY = nFromY or 171
	if not szPlayerName then
		me.CenterMsg("未知名字, 无法发送互动表情");
		return 0;
	end
	self.pPanel:ChangePosition("Sprite", -93, nFromY)
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

local tbMsgMap = {
	{"问好", [==[「$M」拱手作揖。很有礼貌地对「$P」说：“在下「$M」，请多指教！”]==]},
	{"亲吻", [==[「$M」轻轻地捧起「$P」的脸，给了「$P」一个无限温柔的吻。#16]==]},
	{"痴情", [==[「$M」痴痴地望着「$P」的身影，口水不禁流了一地……#10]==]},
	{"爱意", [==[「$M」拉着「$P」的手，温柔地默默对视。目光中蕴含着千种柔情，万般蜜意。#11]==]},
	{"挑衅①", [==[「$M」拍拍胸脯，对着「$P」咆哮：“你小子有种上来跟我比划比划！#119”]==]},
	{"踢人", [==[「$M」飞起一脚，踢得「$P」转体三周半落地翻滚！#124]==]},
	{"耳光", [==[「$M」狠狠掴了「$P」几记响亮的耳光，打得「$P」眼冒金星。]==]},
	{"乞讨", [==[「$M」抱住「$P」的大腿，一把鼻涕一把泪地说：“这位大侠，您行行好，帮帮俺吧！#117”]==]},
	{"讨厌", [==[「$M」用手指着「$P」的鼻子，一边笑一边骂道：“讨厌，你好坏啊！#35”]==]},
	{"恭喜", [==[「$M」对「$P」说道：“恭喜！恭喜！#49#49”]==]},

	{"傻笑", [==[「$M」冲着「$P」呵呵地傻笑着……#7]==]},
	{"偷吻", [==[「$M」趁「$P」不注意，以迅雷不及掩耳之势在「$P」脸上亲了一下……#13]==]},
	{"景仰", [==[「$M」讨好地对「$P」说道：“在下对阁下的景仰之情，犹如滔滔江水连绵不绝。#12”]==]},
	{"媚眼", [==[「$M」对「$P」使了一个媚眼#17，「$P」心中顿时小鹿乱撞。]==]},
	{"挑衅②", [==[「$M」剑眉一轩，冷冷的瞥了「$P」一眼，淡淡说道：“你，不是我的对手。#111”]==]},
	{"敲头", [==[「$M」抡起手中双锤对准「$P」的脑袋狠狠敲下#20，狞笑道：“你给我发呆去吧！”]==]},
	{"阴险", [==[「$M」望着「$P」的背影，嘴角上扬发出阴险的笑声：“嘿嘿嘿~#6”。]==]},
	{"厚颜", [==[「$M」对「$P」怒道：“游历数十载，从未见过有如此厚颜之徒。#30”]==]},
	{"发疯", [==[「$M」摇摇头，叹气道：“完了，「$P」发疯了#43……”]==]},
	{"赞扬", [==[「$M」指着「$P」赞叹道：“厉害了我的哥！#53#53”]==]},
};

function tbUi:OnOpenEnd(szPlayerName)
	self.szPlayerName = szPlayerName;

	for nIdx, tbMsgInfo in ipairs(tbMsgMap) do
		local szTitle = tbMsgInfo[1];
		self.pPanel:Button_SetText("Position" .. nIdx, szTitle);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

for nIdx, tbMsgInfo in ipairs(tbMsgMap) do
	tbUi.tbOnClick["Position" .. nIdx] = function (self)
		local szMsg = tbMsgInfo[2];
		szMsg = string.gsub(szMsg, "$P", self.szPlayerName) or szMsg;
		szMsg = string.gsub(szMsg, "$M", me.szName) or szMsg;
		if Ui:WindowVisible("ChatLargePanel") ~= 1 then
			Ui:OpenWindow("ChatLargePanel");
		end
		Ui("ChatLargePanel"):AddMsg2Input(szMsg);
		Ui:CloseWindow(self.UI_NAME);
	end
end