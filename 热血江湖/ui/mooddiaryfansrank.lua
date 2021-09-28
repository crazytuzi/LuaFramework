-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_moodDiary_fansRank = i3k_class("wnd_moodDiary_fansRank", ui.wnd_base)

local LAYER_FANSITEM = "ui/widgets/gongxianpaihangt"
local z_rankImg = {1659, 1660, 1661} --1,2,3 排名图片

function wnd_moodDiary_fansRank:ctor()
	self.moodDiary = {}
end

function wnd_moodDiary_fansRank:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_moodDiary_fansRank:refresh(moodDiary)
	self.moodDiary = moodDiary
	self:updateFansRank(moodDiary)
end

function wnd_moodDiary_fansRank:updateFansRank(moodDiary)
	local widgets = self._layout.vars
	local diaryDecorate = i3k_db_mood_diary_decorate[self.moodDiary.curDecorate]
	if diaryDecorate then
		widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.fansRankBg))
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.fansRankTitle))
		widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.fansRankBoard))
		widgets.rank_text:setTextColor(diaryDecorate.fansRankTextColor)
		widgets.head_text:setTextColor(diaryDecorate.fansRankTextColor)
		widgets.name_text:setTextColor(diaryDecorate.fansRankTextColor)
		widgets.level_text:setTextColor(diaryDecorate.fansRankTextColor)
		widgets.contri_text:setTextColor(diaryDecorate.fansRankTextColor)
		widgets.close_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.fansRankCloseIcon))
		widgets.scrollIcon:setImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.wndScrollIcon))
	end
	widgets.rank_scroll:removeAllChildren()
	if #moodDiary.fans>0 then
		for i=1,#self.moodDiary.fans do
			local Item = require(LAYER_FANSITEM)()
			local name = Item.vars.name_label
			local level = Item.vars.level_label
			local txb_img = Item.vars.txb_img
			local icon = Item.vars.icon
			local power = Item.vars.power_label
			local bestThree = Item.vars.best_three
			local fourth = Item.vars.fourth
			if i>3 then
				bestThree:setVisible(false)
				fourth:setVisible(true)
				fourth:setText(i..".")
				if diaryDecorate then
					fourth:setTextColor(diaryDecorate.fansRanksColor)
				end
			else
				bestThree:setVisible(true)
				fourth:setVisible(false)
				bestThree:setImage(g_i3k_db.i3k_db_get_icon_path(z_rankImg[i]))
			end
			name:setText(moodDiary.fans[i].role.name)
			level:setText(moodDiary.fans[i].role.level)
			power:setText(moodDiary.fans[i].value)
			
			local BWType = moodDiary.fans[i].role.bwType
			local frameId = moodDiary.fans[i].role.headBorder
			txb_img:setImage(g_i3k_get_head_bg_path(BWType, frameId)) 
			
			local headicon = moodDiary.fans[i].role.headIcon
			icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))
			if diaryDecorate then
				Item.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(diaryDecorate.fansRankScroll))
				Item.vars.name_label:setTextColor(diaryDecorate.fansNameColor)
				Item.vars.power_label:setTextColor(diaryDecorate.fansRankColor)
				Item.vars.level_label:setTextColor(diaryDecorate.fansRankColor)
			end
			widgets.rank_scroll:addItem(Item)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_moodDiary_fansRank.new()
	wnd:create(layout)
	return wnd
end
