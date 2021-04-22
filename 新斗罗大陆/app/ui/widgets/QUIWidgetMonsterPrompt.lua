local QUIWidget = import(".QUIWidget")
local QUIWidgetMonsterPrompt = class("QUIWidgetMonsterPrompt", QUIWidget)
local QUIWidgetMonsterHead = import("..widgets.QUIWidgetMonsterHead")

local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetMonsterPrompt:ctor(options)
  local ccbFile = "ccb/Widget_MonstarPrompt.ccbi"
  local callBacks = {}
  QUIWidgetMonsterPrompt.super.ctor(self, ccbFile, callBacks, options)
  
  if options ~= nil then
    self.info = options.info
    -- self._size = options.size
    self._scale = options.scale or 1
    self.config = options.config
    self._isHideLevel = options.isHideLevel or false
  end
  self:getOldSize()
  self.chineseSize = 21
  
  self._ccbOwner.boss:setVisible(false)
  self._ccbOwner.monster_name:setString("")
  self._ccbOwner.monster_level:setString("")
  self._ccbOwner.monster_skill1:setString("")
  self._ccbOwner.monster_skill2:setString("")
  self._ccbOwner.monster_skill3:setString("")
  self._ccbOwner.monster_content:setString("")

  self.size = self._ccbOwner.monster_bg:getContentSize()

  --设置头像
  -- self._headContent = CCNode:create()
  -- local ccclippingNode = QFullCircleUiMask.new()
  -- ccclippingNode:setRadius(self._scale * (self.size.width/2 - 5))
  -- ccclippingNode:addChild(self._headContent)
  -- self._ccbOwner.node_head:addChild(ccclippingNode)
  
  -- local headImageTexture = CCTextureCache:sharedTextureCache():addImage(self.info.icon)
  -- self._imgSp = CCSprite:createWithTexture(headImageTexture)
  -- local imgSize = self._imgSp:getContentSize()
  -- self._imgSp:setScale(self._scale * self.size.width/imgSize.width)
  -- self._ccbOwner.node_head:addChild(self._imgSp)
  local character = QStaticDatabase:sharedDatabase():getCharacterByID(self.config.npc_id)
  local characterData = QStaticDatabase:sharedDatabase():getCharacterData(self.config.npc_id, character.data_type, self.config.npc_difficulty, self.config.npc_level)
  local head = QUIWidgetMonsterHead.new(self.config)
  head:setHero(self.config.npc_id)
  head:setStar(characterData.grade or 0)
  head:setBreakthrough(characterData.breakthrough or 0)
  self._ccbOwner.node_head:addChild(head)
  
  self:setAll()
end

function QUIWidgetMonsterPrompt:setAll()
  -- assert(self.config.npc_level, "npc_id为 ：".. self.config.npc_id .." 的 npc_level 为空")
  self._ccbOwner.monster_name:setString(self.info.name)
  if not self._isHideLevel then
    self._ccbOwner.monster_level:setString("LV.".. (self.config.npc_level or 0))
  else
    self._ccbOwner.monster_level:setString("")
  end
  self._ccbOwner.monster_content:setString(q.autoWrap(self.info.desc or "", self.chineseSize, 40/3 , self.oldSkillSize.width))

  if self.config.is_boss ~= nil and self.config.is_boss == true then
    self._ccbOwner.boss:setVisible(true)
    self:getBossSkill()
  else
    self._ccbOwner.monster_skill1:setString(q.autoWrap(self.info.brief or "", self.chineseSize, 40/3 , self.oldSkillSize.width))
  end
  self:setContentBg()
  self:setPromptBg()
end

--设置整个悬浮提示框的大小
function QUIWidgetMonsterPrompt:setPromptBg()
  local promptWidth = self._ccbOwner.monster_bg:getContentSize().width
  local headSize = self.size.height
--  local frameSize = self._ccbOwner.kuang_bg:getContentSize().height 
--  local frameChang = frameSize - self.oldFrameSize.height
  self._ccbOwner.monster_bg:setScaleY((self.oldBgSize.height + self.skillChange)/self.oldBgSize.height)
end

function QUIWidgetMonsterPrompt:setContentBg()
  self.skillSize1 = self._ccbOwner.monster_skill1:getContentSize().height
  self.skillSize2 = self._ccbOwner.monster_skill2:getContentSize().height
  self.skillSize3 = self._ccbOwner.monster_skill3:getContentSize().height
  self.skillChange1 = self.skillSize1 - self.oldSkillSize.height
  if self._ccbOwner.monster_skill2:getString() == "" then
    self.skillChange2 = -24
  else
    self.skillChange2 = self.skillSize2 - self.oldSkillSize.height
  end
  if self._ccbOwner.monster_skill3:getString() == "" then
    self.skillChange3 = -24
  else
    self.skillChange3 = self.skillSize3 - self.oldSkillSize.height
  end
  self.skillChange = self.skillChange1 + self.skillChange2 + self.skillChange3
  self._ccbOwner.monster_skill2:setPosition(self.oldSkillPosition2.x, self.oldSkillPosition2.y - self.skillChange1)
  self._ccbOwner.monster_skill3:setPosition(self.oldSkillPosition3.x, self.oldSkillPosition3.y - self.skillChange1 - self.skillChange2)
  self._ccbOwner.frame_node:setPosition(0, -self.skillChange)
end

--获取各项初始值
function QUIWidgetMonsterPrompt:getOldSize()
  self.oldBgSize = self._ccbOwner.monster_bg:getContentSize()
  -- nzhang: temp fix for monster_skill1 content size is not decided.
  local oldString = self._ccbOwner.monster_skill1:getString()
  self._ccbOwner.monster_skill1:setString("")
  self._ccbOwner.monster_skill1:setString(oldString)
  self.oldSkillSize = self._ccbOwner.monster_skill1:getContentSize()
  self.oldFrameSize = self._ccbOwner.kuang_bg:getContentSize()
  self.oldSkillPosition1 = ccp(self._ccbOwner.monster_skill1:getPosition())
  self.oldSkillPosition2 = ccp(self._ccbOwner.monster_skill2:getPosition())
  self.oldSkillPosition3 = ccp(self._ccbOwner.monster_skill3:getPosition())
end

--获取boss技能
function QUIWidgetMonsterPrompt:getBossSkill()
  if self.info.skill_desc_1 ~= nil then
    self._ccbOwner.monster_skill1:setString(q.autoWrap(self.info.skill_name_1.."："..self.info.skill_desc_1, self.chineseSize, 40/3 , self.oldSkillSize.width))
  end
  if self.info.skill_desc_2 ~= nil then
    self._ccbOwner.monster_skill2:setString(q.autoWrap(self.info.skill_name_2.."："..self.info.skill_desc_2, self.chineseSize, 40/3 , self.oldSkillSize.width))
  end
  if self.info.skill_desc_3 ~= nil then
    self._ccbOwner.monster_skill3:setString(q.autoWrap(self.info.skill_name_3.."："..self.info.skill_desc_3, self.chineseSize, 40/3 , self.oldSkillSize.width))
  end
end

return QUIWidgetMonsterPrompt