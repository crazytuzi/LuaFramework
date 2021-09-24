local ArtifactLayer   = classGc(view,function ( self,_uid )
	self.m_winSize    = cc.Director : getInstance() : getVisibleSize()
	
	self.m_curRoleUid = _uid or 0
	self.m_myUid      = self.m_curRoleUid
end)

local viewSize = cc.size(360,360)
local FONTSIZE = 20
local ONE_TAG  = 111
local TWO_TAG  = 112
local THR_TAG  = 113
local FOR_TAG  = 114

function ArtifactLayer.create(self,_idx,_true)
    if self.m_rootLayer~=nil then return end
    self.magicData=_G.Cfg.magic_des[_idx]
    self.isTrue=_true
    self.artifactId=_idx

  	self.m_rootLayer  = cc.Node : create()
    self:__init()
    self:__initView()

    local msg = REQ_MAGIC_EQUIP_REQUEST_ONE()
    msg       : setArgs(_idx)
    _G.Network: send(msg)
    
    return self.m_rootLayer
end

function ArtifactLayer.updataIndex(self,_idx,_true)
    print("updataIndex==>>",_idx,_true)
    self.magicData=_G.Cfg.magic_des[_idx]
    self.isTrue=_true
    self.artifactId=_idx

    local msg = REQ_MAGIC_EQUIP_REQUEST_ONE()
    msg       : setArgs(_idx)
    _G.Network: send(msg)
end

function ArtifactLayer.__init(self)
    self : register()
end

function ArtifactLayer.register(self)
    self.pMediator = require("mod.artifact.ArtifactMediator")(self)
end
function ArtifactLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ArtifactLayer.__initView( self )
	print("..............创建神兵面板..............")
  local titleLab=_G.Util:createLabel("属性",FONTSIZE+4)
  titleLab:setPosition(30,155)
  self.m_rootLayer:addChild(titleLab)

  self.attrLab = {}
  local posX = -110
  local posY = 148 
  for i=1,8 do
      if i%2==1 then
        posX = -110
        posY = posY-35
      else
        posX = posX+160
      end
      self.attrLab[i] = _G.Util : createLabel("",FONTSIZE)
      -- self.attrLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
      self.attrLab[i] : setAnchorPoint(cc.p(0,0.5)) 
      self.attrLab[i] : setPosition(cc.p(posX,posY))
      self.m_rootLayer : addChild(self.attrLab[i])
  end

	local lineSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSize = lineSpr1:getContentSize()
	lineSpr1 : setPreferredSize(cc.size(viewSize.width-2,lineSize.height))
	lineSpr1 : setPosition(30,-20)
	self.m_rootLayer : addChild(lineSpr1)

  local skillSpr = cc.Sprite:createWithSpriteFrameName("battle_skill_box.png") 
  skillSpr:setPosition(-85, -72)
  self.m_rootLayer : addChild( skillSpr )

  self:updateSkillIcon(self.magicData.skill[1])

  local skillData=_G.Cfg.skill[self.magicData.skill[1]]
  if skillData==nil then
      skillData=_G.Cfg.skill[48140]
  end
  local skillName=skillData.name
  self.skillNameLab=_G.Util:createLabel(skillName,FONTSIZE+2)
  self.skillNameLab:setAnchorPoint( cc.p(0.0,0.5) )
  self.skillNameLab:setPosition(-30,-40)
  self.m_rootLayer:addChild(self.skillNameLab)

  local content=skillData.lv[1].remark
  self.skillLab=_G.Util:createLabel(content,FONTSIZE)
  self.skillLab:setPosition(-30,-95)
  self.skillLab:setDimensions(viewSize.width/2+50, 80)
  self.skillLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  self.skillLab:setAnchorPoint( cc.p(0.0,0.5) )
  self.m_rootLayer:addChild(self.skillLab)

	local function local_btncallback(sender, eventType) 
	    if eventType==ccui.TouchEventType.ended then
	        local nTag=sender:getTag()
          if nTag==ONE_TAG then
              print("获取界面")
              _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_BAG,nil,5,2)
          elseif nTag==TWO_TAG then
              print("激活协议")
              local bagData=_G.GBagProxy : getEquipmentList()
              for k,v in pairs(bagData) do
                print(k,v.index,v.goods_id)
                if v.goods_id==self.magicData.id then
                  self.bagIdx=v.index
                end
              end
              local msg = REQ_GOODS_USE()
              msg       : setArgs(1,0,self.bagIdx,1)
              _G.Network: send(msg)
          elseif nTag==THR_TAG then
              print("使用协议")
              local msg = REQ_MAGIC_EQUIP_USE()
              msg       : setArgs(self.artifactId)
              _G.Network: send(msg)
          else
              print("卸下协议")
              local msg = REQ_MAGIC_EQUIP_USE()
              msg       : setArgs(0)
              _G.Network: send(msg)
          end
	    end
  end
  self.m_goldbtn = gc.CButton:create("general_btn_gold.png") 
  self.m_goldbtn : setTitleFontName(_G.FontName.Heiti)
  self.m_goldbtn : setTitleText("获 取")
  self.m_goldbtn : addTouchEventListener(local_btncallback)
  self.m_goldbtn : setTitleFontSize(22)
  self.m_goldbtn : setPosition(30,-160)
  self.m_goldbtn : setTag(ONE_TAG)
  self.m_rootLayer : addChild(self.m_goldbtn)
end

function ArtifactLayer.updateSkillIcon( self,skillId)
  if self.headspr~=nil then 
    self.headspr:removeFromParent(true)
    self.headspr=nil
  end
  self.headspr = _G.ImageAsyncManager:createSkillSpr(skillId)
  self.headspr : setPosition( -85, -72 )
  self.m_rootLayer : addChild( self.headspr )
end

function ArtifactLayer.updateAttrData( self,_data)
    local attrNum={_data.attr_xxx.att,_data.attr_xxx.hp,_data.attr_xxx.wreck,_data.attr_xxx.def,
          _data.attr_xxx.hit,_data.attr_xxx.dod,_data.attr_xxx.crit,_data.attr_xxx.crit_res}
    local attrName={ "攻击", "气血", "破甲", "防御", "命中", "闪避", "暴击", "抗暴", }
    for i=1,8 do
      self.attrLab[i]:setString(string.format("%s+%d",attrName[i],attrNum[i]))
    end
    local skillLv=_data.skill_lv
    if skillLv<1 then skillLv=1 end
    local skillData=_G.Cfg.skill[self.magicData.skill[1]]
    if skillData==nil then
        skillData=_G.Cfg.skill[48140]
    end
    print("skillData",self.skillLab,skillData,skillLv)
    self:updateSkillIcon(self.magicData.skill[1])
    local content=skillData.lv[skillLv].remark
    self.skillNameLab:setString(skillData.name)
    self.skillLab:setString(content)
    local goodNums = _G.GBagProxy:getGoodsCountById(self.magicData.id)
    print("self.magicData.id",self.magicData.id,goodNums)
    if _data.flag==1 then
        self.m_goldbtn : setTitleText("卸 下")
        self.m_goldbtn : setTag(FOR_TAG)
    elseif self.isTrue==true then
        self.m_goldbtn : setTitleText("使 用")
        self.m_goldbtn : setTag(THR_TAG)
    elseif goodNums>0 then
        self.m_goldbtn : setTitleText("激 活")
        self.m_goldbtn : setTag(TWO_TAG)
    else
        self.m_goldbtn : setTitleText("获 取")
        self.m_goldbtn : setTag(ONE_TAG)
    end
end

function ArtifactLayer.updateBtnStr( self , res)
    if res==2 then
        local goodNums = _G.GBagProxy:getGoodsCountById(self.magicData.id)
        print("goodNums==>>>",goodNums)
        if goodNums>0 then
          self.m_goldbtn : setTitleText("激 活")
          self.m_goldbtn : setTag(TWO_TAG)
        end
        return
    end
    if res==1 then
        self.m_goldbtn : setTitleText("卸 下")
        self.m_goldbtn : setTag(FOR_TAG)
    else
        self.m_goldbtn : setTitleText("使 用")
        self.m_goldbtn : setTag(THR_TAG)
    end
end

return ArtifactLayer