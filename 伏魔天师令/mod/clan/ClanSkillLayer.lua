local ClanSkillLayer = classGc(view, function(self)
    self.pMediator = require("mod.clan.ClanSkillLayerMediator")()
    self.pMediator : setView(self)

    self.Lv = {}
end)

local FONT_SIZE  = 20

function ClanSkillLayer.__create(self)
  --外层绿色底图大小
  self.m_rootBgSize = cc.size(848,492)

  --左底图
  self.m_bgSpr      = cc.Node : create()
  self.m_bgSpr      : setPosition(-self.m_rootBgSize.width/2+3,-self.m_rootBgSize.height/2-55)

  local X_width     = self.m_rootBgSize.width  - 110
  local Y_height    = 29
  local Spr_Input   = ccui.Scale9Sprite : createWithSpriteFrameName( "general_friendbg.png" )
  Spr_Input         : setContentSize(cc.size(self.m_rootBgSize.width,55) )
  Spr_Input         : setPosition( self.m_rootBgSize.width/2 ,Y_height )
  self.m_bgSpr      : addChild( Spr_Input, 5 )

  self.m_GXLab = _G.Util:createLabel("",FONT_SIZE)
  self.m_GXLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  self.m_GXLab : setPosition( X_width ,Y_height-3 )
  self.m_GXLab : setAnchorPoint(cc.p(0,0.5))
  self.m_bgSpr : addChild(self.m_GXLab, 10)

  local myGong = _G.Util:createLabel("个人贡献：",FONT_SIZE)
  -- myGong : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  myGong : setPosition( X_width-50 ,Y_height-3 )
  self.m_bgSpr : addChild(myGong, 10)

  local function local_btncallback(sender, eventType) 
      return self : onbtncallback(sender, eventType)
  end

  self.m_skillLab_attr = {} 
  self.skillSpr        = {} 
  self.myLv = {}

  -- self.myWidget1  = {}
  -- self.myWidget2  = {}

  local color1    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LBLUE )
  local color2    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
  local color3    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )
  local color4    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD )
  local oneSize   = cc.size( 203, 428 )
  local skillname  = {"易经洗髓","战意滔天","真元护体","无坚不摧"}
  local skillpng = {"clan_skill_rebirth_2.png","clan_skill_rage_2.png","clan_skill_guard_2.png","clan_skill_invin_2.png"}
  local m_colorStr= { color4, color4, color4 }
  local m_color2  = { color3, color3, color3 }
  local m_Spr     = { "general_hp.png", "general_att.png", "general_def.png", "general_wreck.png" } 
  local mytest2   = { "气  血：", "攻  击：", "防  御：", "破  甲：" }
  local mytest    = { "攻击：", "每级提升：", "消耗贡献：" }

  for i=1,4 do
      local m_onebgspr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" ) 
      m_onebgspr       : setPreferredSize( oneSize )
      self.m_bgSpr     : addChild(m_onebgspr)
      m_onebgspr       : setPosition(oneSize.width/2+8+(i-1)*(oneSize.width+6),oneSize.height/2+57)

      local headSpr = cc.Sprite : createWithSpriteFrameName("general_titlebg.png")
      m_onebgspr    : addChild(headSpr)
      headSpr       : setPosition(oneSize.width/2,oneSize.height-33)

      local skillNameLab = _G.Util : createLabel( skillname[i], FONT_SIZE+4 )
      skillNameLab : setColor(color4)
      skillNameLab : setPosition( oneSize.width/2,oneSize.height-35) 
      m_onebgspr   : addChild( skillNameLab,20 )

      local skillSpr = cc.Sprite : createWithSpriteFrameName( skillpng[i] ) 
      m_onebgspr     : addChild(skillSpr,6)
      skillSpr       : setPosition(oneSize.width/2, oneSize.height-170)
      self.skillSpr[i] = skillSpr

      local m_SprShow  = cc.Sprite : createWithSpriteFrameName( m_Spr[i] ) 
      m_onebgspr : addChild(m_SprShow)
      m_SprShow  : setPosition(40,166)

      self.myLv[i] = _G.Util : createLabel( "Lv.40", FONT_SIZE )
      -- self.myLv[i] : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
      self.myLv[i] : setPosition( oneSize.width/2,oneSize.height-70) 
      m_onebgspr   : addChild( self.myLv[i],20 )
      
      local m_attrLab = {}
      local lab = {}
      for k=1,3 do
        lab[k] = _G.Util:createLabel(mytest[k],FONT_SIZE)
        -- lab[k] : setColor(m_colorStr[k])
        lab[k] : setAnchorPoint(cc.p(0,0.5))

        m_attrLab[k] = _G.Util:createLabel("",FONT_SIZE)
        m_attrLab[k] : setColor(m_color2[k])       
        m_attrLab[k] : setAnchorPoint(cc.p(0,0.5))

        lab[k] : setPosition(30,165-(k-1)*35)
        m_attrLab[k] : setPosition(lab[k]:getContentSize().width+35,165-(k-1)*35)
        m_onebgspr   : addChild(lab[k])
        m_onebgspr   : addChild(m_attrLab[k])
      end
      lab[1] : setPosition(59,165) 
      lab[1] : setString( mytest2[i] )
      m_attrLab[1] : setPosition(123,165)

      local m_goupBtn  = gc.CButton:create() 
      m_goupBtn  : setTitleFontName(_G.FontName.Heiti)
      m_goupBtn  : loadTextures("general_btn_gold.png")
      m_goupBtn  : setTitleText("提 升")
      m_goupBtn  : setTag(_G.Const["CONST_CLAN_SKILL_PLACE_"..i])
      m_goupBtn  : setTitleFontSize(FONT_SIZE+4)
      m_goupBtn  : addTouchEventListener(local_btncallback)
      m_onebgspr : addChild(m_goupBtn)
      m_goupBtn  : setPosition(oneSize.width/2,45-7)  

      self.m_skillLab_attr[i]   = m_attrLab
  end

  self:AttrFryNode(self.m_rootBgSize,self.m_bgSpr)

  return self.m_bgSpr
end

function ClanSkillLayer.NetworkSend( self )
    self.btn_skill = false
    local msg = REQ_CLAN_ASK_CLAN_SKILL()
    _G.Network :send( msg)
end

function ClanSkillLayer.onbtncallback( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      print("提升按钮回调",btn_tag)

      local msg = REQ_CLAN_STUDY_SKILL()
      msg :setArgs( btn_tag )
      _G.Network :send( msg)

      self.btn_skill = true
    end
end

function ClanSkillLayer.unregister(self)
  if self.pMediator ~= nil then
     self.pMediator : destroy()
     self.pMediator = nil 
  end
end


function ClanSkillLayer.NetWorkReturn_skillDataFromSever( self,m_stamina,m_count,m_attr_msg )
   print("----NetWorkReturn_skillDataFromSever--->",m_stamina,m_count,m_attr_msg)

   if self.btn_skill then
      self.btn_skill = false
      _G.Util:playAudioEffect("ui_equip_add_magic")
   end

   if self.firstIn then
      for k,v in pairs(m_attr_msg) do
        local num = self : getSkillPosition(v.type)
        if self.Lv[num] < v.skill_lv then
           print( "第", num, "个技能变动，产生动画!" )
           self : doTexiao( num )
        end
      end
   end
   self.firstIn = true

   self.m_GXLab : setString(m_stamina or "")
   if m_attr_msg ~= nil then
      for k,v in pairs(m_attr_msg) do
         local m_no     = self : getSkillPosition(v.type)
         print("----->",v.type,m_no)
         local typename = _G.Lang.type_name[v.type] or ""

         if m_no ~= nil and m_no <= 4 then
            self.Lv[m_no]   = v.skill_lv
            self.myLv[m_no] : setString( string.format("Lv.%d",v.skill_lv) )
            local m_attrLab = self.m_skillLab_attr[m_no]
            m_attrLab[1] : setString(v.value)
            -- self.myWidget1[m_no] : setContentSize( cc.size( 86 + m_attrLab[1]:getContentSize().width, 0 ) )
            m_attrLab[2] : setString(v.add_value)
            m_attrLab[3] : setString(v.cast)
            -- self.myWidget2[m_no] : setContentSize( cc.size( 90 + m_attrLab[2]:getContentSize().width, 0 ) )
         end
      end
   end
end

function ClanSkillLayer.doTexiao( self, num )
  self.skillSpr[num] : runAction( 
                          cc.Sequence:create(
                                    cc.ScaleTo:create( 0.15, 1.2 ),
                                    cc.ScaleTo:create( 0.15, 1 )
                                            )
                                 )
end

function ClanSkillLayer.getSkillPosition(self,_type)
   local m_no = nil 
   if _type == _G.Const.CONST_CLAN_SKILL_PLACE_1 then
      m_no = 1 
   elseif _type == _G.Const.CONST_CLAN_SKILL_PLACE_2 then
      m_no = 2 
   elseif _type == _G.Const.CONST_CLAN_SKILL_PLACE_3 then
      m_no = 3 
   elseif _type == _G.Const.CONST_CLAN_SKILL_PLACE_4 then
      m_no = 4 
   end
   return m_no
end

function ClanSkillLayer.AttrFryNode(self,_pos,_obj)
  local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
  attrFryNode:setPosition(_pos.width/2,_pos.height/2)
  _obj:addChild(attrFryNode,1000)
end

return ClanSkillLayer