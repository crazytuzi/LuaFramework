
local Xiakecell = class("Xiakecell", BaseLayer)

function Xiakecell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.Leaderboard.Leaderboardcell_xiakebang")

end

function Xiakecell:initUI( ui )

	self.super.initUI(self, ui)

	self.bg = TFDirector:getChildByPath(ui, "bg")
	self.bg.logic = self
	self.bg:setTouchEnabled(true)

	--选择框设置不可见
	self.bg_select = TFDirector:getChildByPath(ui, "bg_select")	
	self.bg_select:setVisible(false)

	self.Img_paiming = TFDirector:getChildByPath(ui, "Img_paiming")
	self.txt_paiming = TFDirector:getChildByPath(ui, "txt_paiming")
	self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
	self.txt_zhandouli = TFDirector:getChildByPath(ui, "txt_zhandouli")
	self.txt_zhandouli_word = TFDirector:getChildByPath(ui, "txt_zhandouli_word")
	self.Btn_zan = TFDirector:getChildByPath(ui, "Btn_zan")
	self.txt_zan = TFDirector:getChildByPath(ui, "txt_zan")
	self.txt_chiyouzhe = TFDirector:getChildByPath(ui, "txt_chiyouzhe")
	self.img_touxiang = TFDirector:getChildByPath(ui, "img_touxiang")
	self.img_lv = TFDirector:getChildByPath(ui, "img_lv")
	self.txt_lv_word = TFDirector:getChildByPath(ui, "txt_lv_word")
	self.img_pinzhiditu = TFDirector:getChildByPath(ui, "img_pinzhiditu")
	self.img_zhiye = TFDirector:getChildByPath(ui, "img_zhiye")

	self.btn_more = TFDirector:getChildByPath(ui, "btn_more")
	self.btn_more.logic = self
	self.btn_more:setVisible(false)

	self.Img_paiming_data = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}

	self.Btn_zan.logic = self

end

function Xiakecell:removeUI()
	
	self.super.removeUI(self)

end

function Xiakecell:dispose()
	 self:removeEvents()
	 self:removeUI()
end

function Xiakecell:registerEvents()
	self.super.registerEvents(self)

	self.btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GetMoreButtonClick))
	self.Btn_zan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ZanButtonClick))
	self.bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchBgCell))
end

function Xiakecell:removeEvents()

    self.super.removeEvents(self)

    self.btn_more:removeMEListener(TFWIDGET_CLICK)
    self.Btn_zan:removeMEListener(TFWIDGET_CLICK)
    self.bg:removeMEListener(TFWIDGET_CLICK)
end

function Xiakecell:SetData(layer,item)
	
	self.layer = layer
	self.item = item
		
	if item == nil then
		--加载更多
		self.moreBtnType = true
		self.bg:setVisible(false)
		self.btn_more:setVisible(true)
		self.img_pinzhiditu:setVisible(false)
	else
		self.bg:setVisible(true)
		self.btn_more:setVisible(false)
		self.moreBtnType = false

		--设置选中框是否可见
		if item.ranking == layer.cell_select_index then
			self.bg_select:setVisible(true)
		else
			self.bg_select:setVisible(false)
		end

		--设置zan按钮是否有效
		if NiuBilityManager:isCanPraise(item.playerId) then
			self.Btn_zan:setTouchEnabled(true)
			self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan.png')
		else
			self.Btn_zan:setTouchEnabled(false)
			self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan2.png')
		end

		--设置赞的个数
		--self.txt_zan:setString(item.goodNum.."赞")
		self.txt_zan:setString(stringUtils.format(localizable.common_zan,item.goodNum))

		self.img_pinzhiditu:setVisible(true)
		self.txt_name:setString(item.name)
		self.txt_zhandouli:setVisible(true)
		self.txt_zhandouli_word:setVisible(true)
		self.txt_zhandouli_word:setString(item.value)
		self.txt_lv_word:setText(item.roleLevel)

		local RoleIcon = RoleData:objectByID(item.roleId)
		self.img_touxiang:setTexture(RoleIcon:getIconPath())
		print("RoleIconRoleIcon = ", item)
        -- self.img_pinzhiditu:setTexture(GetColorIconByQuality(RoleIcon.quality));
        self.img_pinzhiditu:setTexture(GetColorIconByQuality(item.quality))
        -- self.img_pinzhiditu:setTexture(GetRoleBgByWuXueLevel(item.martialLevel));
        self.img_zhiye:setTexture("ui_new/fight/zhiye_".. RoleIcon.outline ..".png");


		--设置排名
		if item.ranking <= 3 then
			self.Img_paiming:setVisible(true)
			self.Img_paiming:setTexture(self.Img_paiming_data[item.ranking])
			self.txt_paiming:setVisible(false)
		else
			self.Img_paiming:setVisible(false)
			self.txt_paiming:setVisible(true)
			self.txt_paiming:setString(item.ranking)
		end
	end
end

function Xiakecell:setChoiseVisiable( enable )
	self.bg_select:setVisible(enable)
end

function Xiakecell.GetMoreButtonClick(btn)
	local self = btn.logic

	self.layer:UpdateList()
end

function Xiakecell.ZanButtonClick(btn)
	local self = btn.logic
	if self.layer:UpdateZanNum(self.item.playerId) == true then
		self.Btn_zan:setTouchEnabled(false)
		self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan2.png')
	end
end

function Xiakecell.touchBgCell( btn )
	local self = btn.logic
	self.layer:tableCellSelect(self.item.ranking)
end

function  Xiakecell:isMoreButton()
	return self.moreBtnType
end
return Xiakecell