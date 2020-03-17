--任务脚本模板
--强化功能指引

QuestScriptCfg:Add(
{
	name = "strenguide",
	stopQuestGuide = true,--功能引导时是否暂停自动任务引导
	disableFuncKey = true,--使功能键失效
	log = true,--是否记日志
	
	steps = {
		[1] = {
			type = "clickOpenFunc",--类型,点击按钮打开功能
			funcId = 12,--功能id,炼化炉
			complete = function() return UIEquip:IsFullShow(); end,--完成条件,炼化炉主面板打开
			arrow = true,--显示箭头
			arrowPos = 1,--箭头方向(1,2,3,4:上右下左，   箭头的头指向相应方向的中心的)
			arrowOffset = {x=0,y=-5},--箭头偏移(x,y:偏移量)		
			mask = true,
		},
		
		--此步骤为模板,实际子面板是第一个子标签,不需要这步
		[2] = {
			type = "clickOpenUI",--类型,点击按钮开启UI
			button = function() return UIEquip:GetStrenBtn(); end,--要点击的按钮
			complete = function() return UIEquipStren:IsShow(); end,--完成条件(子面板被打开)
			Break = function() return not UIEquip:IsShow(); end,--打断条件(炼化炉主面板关闭)
			arrow = true,--不显示箭头
			arrowPos = 4,--箭头方向(1,2,3,4:上右下左，   箭头的头指向相应方向的中心的)
			arrowOffset = {x=-5,y=0},--箭头偏移(x,y:偏移量)
			mask = true,
		},
	
		[3] = {
			type = "clickButton",--类型,点击按钮
			button = function() return UIEquipStren:GetStrenBtn(); end,--要点击的按钮
			Break = function() return (not UIEquipStren:IsShow()) or (not UIEquip:IsShow()) ; end,--打断条件(子面板关闭)
			arrow = true,--显示箭头
			arrowPos = 1,--箭头方向(1,2,3,4:上右下左，   箭头的头指向相应方向的中心的)
			arrowOffset = {x=0,y=-5},--箭头偏移(x,y:偏移量)
			autoTime = 20000,--自动执行点击的时间
			mask = true,
		}
	}
});