
local tbUi = Ui:CreateClass("ChapterPanel");

tbUi.tbShowInfo = {
	--key = 标题；内容
	["ChapterTitle_01"] = {"月影传说", "序章  柳暗花明又一村"},
	["ChapterTitle_02"] = {"月影传说", "次章  十年不晚君子仇"},
	["ChapterTitle_03"] = {"月影传说", "终章  武林霸图黄粱梦"},
	["ChapterTitle_04"] = {"月影传说", "（完）"},	
	["ChapterTitle_05"] = {"剑侠情缘 壹", "第一章 往日故人今犹在"},
	["ChapterTitle_06"] = {"剑侠情缘 壹", "第二章 碧霞海岛仗剑行"},
	["ChapterTitle_07"] = {"剑侠情缘 壹", "第三章 风雷九州凤九天"},
	["ChapterTitle_08"] = {"剑侠情缘 壹", "第四章 一代恩怨两代仇"},
	["ChapterTitle_09"] = {"剑侠情缘 壹", "第五章 天魔解体动八方"},
	["ChapterTitle_10"] = {"剑侠情缘 壹", "第六章 天山絮雪诉莲心"},
	["ChapterTitle_11"] = {"剑侠情缘 壹", "第七章 兄弟之义手足情"},
	["ChapterTitle_12"] = {"剑侠情缘 壹", "第八章 侠之大者卫山河"},
	["ChapterTitle_13"] = {"剑侠情缘 壹", "（完）"},	
}

function tbUi:OnOpen(szType)
	local tbInfo = self.tbShowInfo[szType] or {"", ""};
	self.pPanel:Label_SetText("ChapterTitle_", tbInfo[1]);
	self.pPanel:Label_SetText("ChapterTitle_2", tbInfo[2]);
end

function tbUi:OnAniEnd(szUiName, szAni)
	if szUiName ~= self.UI_NAME then
		return;
	end

	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_ANIMATION_FINISH,		self.OnAniEnd },
	};

	return tbRegEvent;
end