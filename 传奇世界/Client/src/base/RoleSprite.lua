local RoleSprite = class("RoleSprite", function(strname,isactor) return  SpritePlayer:create(strname,isactor) end)

function RoleSprite:ctor(strname,isactor,params) 

  params[ROLE_SCHOOL] = params[ROLE_SCHOOL] or 1
  params[PLAYER_SEX] = params[PLAYER_SEX] or 1  
  --print("params[PLAYER_SEX]",params[PLAYER_SEX])
  self.sex = params[PLAYER_SEX]
  self:setSex(self.sex)
  self:setType(20+self.sex)
  local dir = params[ROLE_DIR] or 5
  self:initStandStatus(4,6,1.0,dir)
  --self:set5DirMode(true)
  self.isactor = false
  self.arrowIsVisible = true
  self.arrowEffIsVisible = true
  if isactor ~= 0 then
    self.base_data = {}
    self.base_data.spe_skill = {}
    self.skills = {}
    self.wingskills = {}
    self.obj_id = isactor
    self.isactor = true
    G_ROLE_MAIN = self
    local select_effect = Effects:create(false)
    select_effect:setPosition(cc.p(0,-20))
    select_effect:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(select_effect,0,158)
    select_effect:playActionData("roleselect",7,2,-1)
    addEffectWithMode(select_effect,3)

    local sign_effect = Effects:create(false)
    sign_effect:setPosition(cc.p(0,150))
    sign_effect:playActionData2("myselfsign",200,-1,0)
    addEffectWithMode(sign_effect,1)
    self:getTopNode():addChild(sign_effect,200)
    self.sign_effect = sign_effect
    local func = function()
      if getGameSetById(GAME_SET_TOPARROW) == 0 then
        self.sign_effect:setVisible(false)
      end
    end
    performWithDelay(self,func,0.0)

    local role_move_speed = params[ROLE_MOVE_SPEED] or 100
    if role_move_speed then
      local base_speed = getConfigItemByKeys("roleData", {
          "q_zy",
          "q_level",
        },{1,1},"q_move_speed")/1000
      g_speed_time = base_speed * 100.0 / role_move_speed
      if g_speed_time < 0.08 then g_speed_time = 0.08 end
    end
    self.skill_node = self:getSkillNode()
  end
  self:setWingNodeVisble(getGameSetById(GAME_SET_WINGHIDE) == 0)
  self:refreshData(params)
  self:showNameAndBlood(true,100)
  self:standed()
end

function RoleSprite:refreshData(params)  
  if params then
    if params[ROLE_MAX_HP] then
      self:setMaxHP(params[ROLE_MAX_HP])
    end
    if params[ROLE_HP] then
      self:setHP(params[ROLE_HP])
      if params[ROLE_HP] > 0 then self:showNameAndBlood(true) end
    end
    if params[ROLE_NAME] then
        local name_label = self:getNameBatchLabel()
        if name_label then
          name_label:setString(params[ROLE_NAME])
          self:setTheName(params[ROLE_NAME])
        end
    end
    if params[ROLE_LEVEL] then
       self:setLevel(params[ROLE_LEVEL])
    end
    self:initData(params) 
  end

  if params and params[ROLE_SCHOOL] then
    local zhiye={"t_zh","t_fs","t_ds"}
    local sex = {"_m","_f"}
    local school = params[ROLE_SCHOOL]
    self.school = school
    self:setSchool(self.school)
  end

end

function RoleSprite:setSignState(isVisible)
  self.sign_state = isVisible
  if isVisible and getGameSetById(GAME_SET_TOPARROW) ~= 0 then
    self.sign_effect:setVisible(true)
  else
    self.sign_effect:setVisible(false)
  end
end

function RoleSprite:setEquipment(e_type,file_path) 
  return self:setEquipment_ex(self,e_type,file_path)
end

function RoleSprite:getRightResID(e_type,w_resId) 
  local res_id = w_resId
  if g_dwon_manage then
    local type_map = {
      [PLAYER_EQUIP_WEAPON] = 4,--武器
      [PLAYER_EQUIP_UPPERBODY] = 5,--衣服
      [PLAYER_EQUIP_WING] = 3,--光翼
      [PLAYER_EQUIP_RIDE] = 6,--坐骑
      --[PLAYER_EQUIP_MEDAL] = 9,--展示界面
    }
    if not type_map[e_type] then type_map[e_type] = e_type end
    local down_index = g_dwon_manage:getDownloadIndex() 
    --print("e_type"..e_type.."w_resId"..w_resId.."type_map[e_type]"..type_map[e_type])
    local res_item =  getConfigItemByKeys("resouceCfg",{"q_type","q_id"},{type_map[e_type],w_resId})
    if res_item and res_item.download_id and down_index <= res_item.download_id then
      if res_item.q_default then
        res_id = res_item.q_default
        -- if (not g_dwon_manage.is_downloading) and ( not ( DATA_Activity and DATA_Activity._____show_nomore ) ) then
        --     if not DATA_Activity.giftLayer then
        --       __GotoTarget( { ru = "a32" } )
        --     end
        -- end
      end
    end

  end
  return res_id
end

function RoleSprite:setEquipments(cl_id,weapon_id,wing_id) 
  local MpropOp = require "src/config/propOp"
  local add_id = 0

  if self.up_ride then
    add_id = 1000
  end

  if cl_id and cl_id > 0 then
    local w_resId = MpropOp.equipResId(cl_id)
    if w_resId <= 0 then w_resId = g_normal_close_id end
    w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+self:getSex()*100000+add_id) 
    local r_path = "role/" .. (w_resId)
    self:setBaseUrl(r_path)
  end
  if weapon_id and weapon_id > 0 then 
    local w_resId = MpropOp.equipResId(weapon_id)
    --w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId+self:getSex()*100000+add_id) 
    w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId) 
    local w_path = "weapon/" .. (w_resId)
    self:setEquipment(PLAYER_EQUIP_WEAPON,w_path)
  end
  if wing_id and wing_id > 0 then 
    local w_resId = getConfigItemByKey("WingCfg","q_ID",wing_id,"q_senceSouceID")
    if w_resId==nil and wing_id<=7 then --有的是直接配的场景资源ID
        w_resId=wing_id
    end
    w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WING,w_resId+100000+add_id) 
    local w_path = "wing/" .. (w_resId)
    self:setEquipment(PLAYER_EQUIP_WING,w_path)
  end
  self:reloadRes()
end

function RoleSprite:setEquipment_ex(role,e_type,file_path)
  local sprite_type = e_type - PLAYER_EQUIP_WEAPON + 2
  local zorder = 10
  if e_type and e_type >= PLAYER_EQUIP_WING then
     sprite_type  = e_type - PLAYER_EQUIP_WEAPON - 6
  end
  if e_type == PLAYER_EQUIP_RIDE or e_type == PLAYER_EQUIP_RIDE+1  then zorder = 8 end
  if file_path then
    role:insertActionChild(file_path,zorder,e_type)
    if e_type == PLAYER_EQUIP_WEAPON and file_path ~= "weapon/1129" then
      local attr = string.sub(file_path, 8)
      if attr ~= nil then
        local weapon_id = tonumber(attr)
        if weapon_id ~= nil then
          role:setWeaponId(weapon_id)
        end
      end
    end
  end
  if role.isHoe and (not file_path or file_path ~= "weapon/1129") then
    self:isChangeToHoe(role, true)
  end
  return equipment
end 

function RoleSprite:doRideAction()
  if self.no_action or self.up_ride then return end
   self:removeRideAction()
  local load_show = cc.Node:create()
  self:getTopNode():addChild(load_show, 9999999)
  load_show:setScale(0.5)
  local spritebg = createSprite(load_show, "res/common/progress/cj1.png", cc.p(0, 50))
  local progress1 = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/cj2.png"))
  progress1:setPosition(cc.p(158, 11))
  progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  progress1:setAnchorPoint(cc.p(0.5,0.5))
  progress1:setBarChangeRate(cc.p(1, 0))
  progress1:setMidpoint(cc.p(0,1))
  progress1:setPercentage(0)
  spritebg:addChild( progress1 )
  local devourpercent = 0
  local update = function()
    devourpercent = devourpercent + 15
    progress1:setPercentage(devourpercent)
    if devourpercent >= 100 then 
      self:removeRideAction()
    end
  end
  self.load_show = load_show
  schedule(load_show,update,0.05)
  --createLabel(load_show, "loading ...", cc.p(0, 50),cc.p(0.5, 0.5),20)
end

function RoleSprite:removeRideAction()
  if self.load_show then
    removeFromParent(self.load_show) 
    self.load_show = nil
    self.no_action = nil
  end
end

-- 针对切地图，主角节点，tileNode 不删除，但是重新挂载，导致特效飘字动作不执行的情况主动清除。
function RoleSprite:RemoveCharText()
    local tileRootNode = self:getTitleNode();
    if tileRootNode then
        local commConst = require("src/config/CommDef");
        local charTextNode = tileRootNode:getChildByTag(commConst.TAG_CHAR_TEXT);
        if charTextNode then
            removeFromParent(charTextNode);
        end
    end
end

function RoleSprite:setSignPos()
  if self.sign_effect then
    local height = 150
    local titleSpr = self:getTitleNode():getChildByTag(100)
    if titleSpr and titleSpr:isVisible() then
      height = height + titleSpr:getContentSize().height * titleSpr:getScale()
    end
    if isShowFacName(self) then
      height = height + 20
    end
    if isShowSpecialTitleName(self) then
      height = height + 20
    end
    if self:getOnRide() then
       height = height + 40
    end
    self.sign_effect:setPosition(cc.p(0,height))
  end
end

function RoleSprite:upOrDownRide_ex(role,ride_id,is_up,unsend) 
  local role = tolua.cast(role,"SpritePlayer")
  if not role then return end
 if (role.isactor and (not G_RIDING_INFO.id[1] )) or (is_up and (not ride_id))  then
      return
  end
  if role:getCurrActionState() == ACTION_STATE_EXCAVATE then return end
  role.up_ride = role:getOnRide()
  local objid = role:getTag()
  if ride_id and g_buffs and g_buffs[objid] and g_buffs[objid][340] then
    ride_id = 8888
  end
  if (role.up_ride and role.ride_id and role.ride_id == ride_id and is_up) then
    return
  elseif ((not role.up_ride) and (not is_up)) then
    return
  end
  if self == role and (not unsend) then
    if (not is_up) then 
      RidingSwitch(0) 
    elseif is_up then 
      local can_ride = getConfigItemByKey( "MapInfo" , "q_map_id" , G_MAINSCENE.mapId, "q_map_ride" ) or 0
      if can_ride ~= 1 then
        return 
      end
      if game.getAutoStatus() == AUTO_MINE and G_MAINSCENE and G_MAINSCENE.map_layer then
        G_MAINSCENE.map_layer:resetHangup()
      end
      --RidingSwitch(1) 
    end
  end
  local MRoleStruct = require("src/layers/role/RoleStruct")
  local MPropOp = require("src/config/propOp")
  local MPackManager = require "src/layers/bag/PackManager"
  local MPackStruct = require "src/layers/bag/PackStruct"
  local pack = MPackManager:getPack(MPackStruct.eDress)
  local eClothing = pack:getGirdByGirdId(MPackStruct.eClothing)
  local eWeapon = pack:getGirdByGirdId(MPackStruct.eWeapon)
  local sex,school = role:getSex(),role:getSchool()
  local add_id = 0  
  role.up_ride = nil
  role.ride_id = nil
  local isHighride = false
  local isHighAttackride = G_NO_OPEN_HIGHTRIDE
  if self == role then
    if G_MY_STEP_SOUND then
         AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
         G_MY_STEP_SOUND = nil
    end
    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer:hasPath() then
      G_MY_STEP_SOUND =  AudioEnginer.randStepMus(is_up,ride_id)
    end
  end
  if is_up then 
    role.up_ride = true
    role.ride_id = ride_id
    role:setOnRide(true)
    add_id = 1000 
    local  w_resId = getConfigItemByKey("RidingCfg","q_ID",ride_id,"q_senceSouceID")
    --w_resId = 1026
    if w_resId then
      w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_RIDE,w_resId) 
      isHighride = (w_resId >= 1019) and (not isHighAttackride)
      role:setIsOnHighRide(isHighride)
      role:setIsOnAttackRide(isHighAttackride)
      local ride = self:setEquipment_ex(role,PLAYER_EQUIP_RIDE,tostring(w_resId).."/down")
    end
    local span_y = -20
    if isHighride then
      span_y = 0
    end
    local select_effect = role:getChildByTag(158)
    if select_effect then
      if self == role then
        select_effect:setPosition(cc.p(0,0 + span_y))
      else
        select_effect:setPosition(cc.p(0,10 + span_y))
      end
    end   
  else 
    role:setOnRide(false)
    role:removeActionChildByTag(PLAYER_EQUIP_RIDE)
    local select_effect = role:getChildByTag(158)
    if select_effect then
      if self == role then
        select_effect:setPosition(cc.p(0,-20))
      else
        select_effect:setPosition(cc.p(0,-10))
      end
    end
  end

  if self == role then
    if is_up then self.down_first = 0 end 
    if eClothing then
      local protoId = MPackStruct.protoIdFromGird(eClothing)
      local w_resId = MPropOp.equipResId(protoId)
      if w_resId <= 0 then w_resId = g_normal_close_id end
      w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+sex*100000+add_id) 
      --if isHighride then w_resId = 6001505 + sex*100000 end
      if isHighAttackride then w_resId = w_resId + 1000 end
      if w_resId > 0 then
        local r_path = "role/" .. (w_resId)
        role:setBaseUrl(r_path)
      else 
        local r_path = "role/" .. (g_normal_close_id+sex*100000+add_id)
        role:setBaseUrl(r_path) 
      end
    else
      local r_path = "role/" .. (g_normal_close_id+sex*100000+add_id)
      --if isHighride then r_path = "role/6010501" end
      role:setBaseUrl(r_path)
    end
    if eWeapon then
      local protoId = MPackStruct.protoIdFromGird(eWeapon)
      local w_resId = MPropOp.equipResId(protoId)
      --w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId+sex*100000+add_id) 
      if isHighAttackride then
        w_resId = w_resId+add_id--RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId+add_id)
      end
      local w_path = "weapon/" .. (w_resId)
      self:setEquipment_ex(role,PLAYER_EQUIP_WEAPON,w_path)
    end
    if G_WING_INFO.id and G_WING_INFO.state == 1 then
      local w_resId = getConfigItemByKey("WingCfg","q_ID",G_WING_INFO.id,"q_senceSouceID")
      w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WING,w_resId+100000+add_id) 
      --if isHighride then w_resId = w_resId + 1000 end
      --if isHighride then w_resId = 102004 end
      local w_path = "wing/" .. (w_resId)
      self:setEquipment_ex(role,PLAYER_EQUIP_WING,w_path)
    end
    self:setSignPos()
  else 
    local dressId = MRoleStruct:getAttr(PLAYER_EQUIP_UPPERBODY,role:getTag())
    local weaponId = MRoleStruct:getAttr(PLAYER_EQUIP_WEAPON,role:getTag())
    local wingId = MRoleStruct:getAttr(PLAYER_EQUIP_WING,role:getTag())
    local w_resId = MPropOp.equipResId(dressId or 0)
    if w_resId <= 0 then w_resId = g_normal_close_id end
    w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+sex*100000+add_id) 
    --if isHighride then w_resId = 6001505 + sex*100000 end
    if w_resId > 0 then
        local r_path = "role/" .. (w_resId)
        role:setBaseUrl(r_path)
    else 
      local r_path = "role/" .. (g_normal_close_id+sex*100000+add_id)
     --if isHighride then r_path = "role/".. (6001505 + sex*100000) end
      role:setBaseUrl(r_path)
    end
    if weaponId then 
      local w_resId = MPropOp.equipResId(weaponId)
      if w_resId > 0 then
        --w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId+sex*100000+add_id) 
        if isHighAttackride then
          w_resId = w_resId+add_id--RoleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId+add_id)
        end
        local w_path = "weapon/" .. (w_resId)
        self:setEquipment_ex(role,PLAYER_EQUIP_WEAPON,w_path)
      end
    end
    if wingId and wingId > 0 then
      local w_resId = getConfigItemByKey("WingCfg","q_ID",wingId,"q_senceSouceID")
      w_resId = RoleSprite:getRightResID(PLAYER_EQUIP_WING,w_resId+100000+add_id) 
      --if isHighride then w_resId = w_resId + 1000 end
      local w_path = "wing/" .. (w_resId)
      self:setEquipment_ex(role,PLAYER_EQUIP_WING,w_path) 
    end
  end
  local run_act_num = 12 
  local height = 100 
  if is_up then 
    run_act_num = 8
    height = 140 
  end
  role:initRunStatus(run_act_num)
  role:showNameAndBlood(true,height)
  role:reloadRes()
  return (self == role)
end

function RoleSprite:isChangeToHoe(role,ischange) 
  role.isHoe = ischange
  if ischange then
      self:setEquipment_ex(role,PLAYER_EQUIP_WEAPON,"weapon/1129")
  else
    local res_id = role:getWeaponId()
    if res_id == 0 then
      role:removeActionChildByTag(PLAYER_EQUIP_WEAPON)
    else
      self:setEquipment_ex(role,PLAYER_EQUIP_WEAPON,"weapon/".. res_id)
      role:reloadRes()
    end
  end
end

function RoleSprite:upOrDownRide(is_up,no_action) 
  tutoRemoveRidingTutoAction()
  if G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) == false then is_up = false end

  if G_MAINSCENE.map_layer.isStory then is_up = G_MAINSCENE.storyNode:isCanUpRide() end

  self.no_action = no_action
  if is_up then
    RidingSwitch(1)
  else
    return self:upOrDownRide_ex(self,G_RIDING_INFO.id[1],is_up)
  end
end

-- 是否能骑战
-- useSkillId -- 主动点击技能按钮释放
function RoleSprite:CanWarAttack(useSkillId)
    if G_MAINSCENE == nil then
        return false;
    end

    if not G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_riding_on_open"), type=1, flag=1};
        end
        return false;
    end

    local can_ride = getConfigItemByKey( "MapInfo" , "q_map_id" , G_MAINSCENE.mapId, "q_map_ride" ) or 0
    if can_ride ~= 1 then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_no_riding"), type=1, flag=1};
        end
        return false;
    end

    -- 是否开启骑战
    if not G_NO_OPEN_HIGHTRIDE then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_open_war_attack"), type=1, flag=1};
        end
        return false;
    end

    --[[
    -- 衣服是否是骑战衣服
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local MPropOp = require("src/config/propOp")
    local MPackManager = require("src/layers/bag/PackManager")
    local MPackStruct = require("src/layers/bag/PackStruct")
    local pack = MPackManager:getPack(MPackStruct.eDress)
    local eClothing = pack:getGirdByGirdId(MPackStruct.eClothing)
    local eWeapon = pack:getGirdByGirdId(MPackStruct.eWeapon)
    if not eClothing then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_cloth_not_fit"), type=1, flag=1};
        end
        return false;
    end
    
    local clothProtoId = MPackStruct.protoIdFromGird(eClothing)
    local clothItem = MPropOp:item(clothProtoId);
    if not clothItem then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_cloth_not_fit"), type=1, flag=1};
        end
        return false;
    end

    -- 某一个属性代表是否能骑战
    ---------------------------------------------------------------
    
    if not eWeapon then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_cloth_not_fit"), type=1, flag=1};
        end
        return false;
    end
    
    local weaponProtoId = MPackStruct.protoIdFromGird(eWeapon)
    if not weaponProtoId then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_cloth_not_fit"), type=1, flag=1};
        end
        return false;
    end

    -- 某一个属性代表是否能骑战
    ---------------------------------------------------------------
    ]]

    if G_RIDING_INFO == nil or G_RIDING_INFO.id == nil or G_RIDING_INFO.id[1] == nil then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_need_sprit_animal"), type=1, flag=1};
        end
        return false;
    end

    local commConst = require("src/config/CommDef");
    local ridePetId = G_RIDING_INFO.id[1];
    if g_buffs and g_buffs[self.obj_id] and g_buffs[self.obj_id][340] then
        ridePetId = commConst.RIDE_ID_SANTO_PANTHER;
    end
    
    if ridePetId <= commConst.RIDE_ID_GOLDEN_HORSE then
        if useSkillId then
            TIPS{str=game.getStrByKey("wr_need_sprit_animal"), type=1, flag=1};
        end
        return false;
    end

    return true;
end

function RoleSprite:setSkills(params)
    self.skills = {}
    local wingTemp = {}
    local skillTemp = {}
    self.wingskills = {}
    self.jjcskills = {}
    for k,v in pairs(params) do
      local skillTable = getConfigItemByKey("SkillCfg","skillID",v[1])
      local jnfenlie = skillTable.jnfenlie
      if jnfenlie == 1 then
        local order = skillTable.q_order
        table.insert(skillTemp,{v,order})
      elseif jnfenlie == 7 then
        local learnLv = skillTable.learnLv
        table.insert(wingTemp,{v,learnLv})
      elseif jnfenlie == 9 then

      end
    end
    local arrange = function(tab1,tab2)
      table.sort(tab2, function(a,b) return a[2] < b[2] end) --技能id跟学习等级不成正比
      for k,v in pairs(tab2) do
        table.insert(tab1,v[1])
      end
    end
    arrange(self.skills,skillTemp)
    arrange(self.wingskills,wingTemp)
end

function RoleSprite:updateSkills(params) 
  if self.skills and self.wingskills then
      local jn = getConfigItemByKey("SkillCfg","skillID",params[1],"jnfenlie")
      local has_fill = false
      if jn then
        if  jn == 1 then
          for k,v in pairs(self.skills)do
            if v[1] == params[1] then
              has_fill = k
              break
            end
          end
          if not has_fill then
            table.insert(self.skills,params)
          else 
            self.skills[has_fill] = params
          end
        elseif jn == 7 then
          for k,v in pairs(self.wingskills) do
            if v[1] == params[1] then
              has_fill = k
              break
            end
          end
          if not has_fill then
            table.insert(self.wingskills,params)
          else 
            self.wingskills[has_fill] = params
          end
        end
      end
  end
end

function RoleSprite:initData(params) 
  if self.isactor then   
    self.base_data.name = params[ROLE_NAME] or self.base_data.name
    self.base_data.level = params[ROLE_LEVEL] or self.base_data.level
    self.base_data.hp = params[ROLE_HP] or self.base_data.hp or 0
    self.base_data.mhp = params[ROLE_MAX_HP] or self.base_data.mhp or 0
    self.base_data.mp = params[ROLE_MP] or self.base_data.mp or 0
    self.base_data.mmp = params[ROLE_MAX_MP] or self.base_data.mmp or 0 
    self.base_data.curr_exp = params[PLAYER_XP] or self.base_data.curr_exp
    self.base_data.equips = self.base_data.equips or {}
    self.base_data.vital = params[PLAYER_VITAL] or self.base_data.vital or 0
    self.base_data.pet_id = params[PLAYER_PET_ID] or self.base_data.pet
  end
end

function RoleSprite:updateData(params) 
  self.base_data.hp = self:getHP()
  --self.base_data.mp = 
end

function RoleSprite:setTitle_ex(role, titleId)
  --log("setTitle_ex")
  if not role then return end

  local nameNode,title_pos = role:getTitleNode(),cc.p(0, 28)
  if isShowFacName(role) then
    title_pos = cc.p(0, 45)
  end
  if nameNode then
    nameNode:removeAllChildren()
    if titleId ~= 0 then
      local resId = getConfigItemByKey("TitleDB", "q_titleID", titleId, "q_pic")
      if resId then
        nameNode:setLocalZOrder(tonumber(resId))
        local titleSpr = createSprite(nameNode, "res/achievement/title/"..resId..".png",title_pos, cc.p(0.5, 0), nil, 0.4)
        if resId >= 1000 then
          titleSpr:setScale(0.8)
        end
        titleSpr:setTag(100)

        if role ~= G_ROLE_MAIN then
          if getGameSetById(GAME_SET_PLAYERTITLE) == 0 then
            titleSpr:setVisible(false)
          end
        end
      end
    end
  end
  if self == role then
    self.has_title = titleId ~= 0
    self:setSignPos()
  end

  self:resetPosForTop(role)
end

function isShowSpecialTitleName(role)
  if role:getTitleName() and role:getTitleName() ~= "" then
    return true
  end

  return false
end

function RoleSprite:setSpecialTitle(role, titleId)
  --log("111111111111111111 setSpecialTitle titleId = "..tostring(titleId))

  local titleName = getConfigItemByKey("SpecialTitleDB", "q_id", titleId, "q_name")
  --dump(titleName)
  local titleColor = getConfigItemByKey("SpecialTitleDB", "q_id", titleId, "q_color")
  if titleColor then
    titleColor = MColor[titleColor]
  end

  if titleName and string.len(titleName) > 0 then
    role:setTitleName(titleName)
    --dump(role:getTitleName())
  else
    role:setTitleName("")
  end

  local titleNameNode = role:getTitleNameBatchLabel()
  if titleNameNode then
    -- if role:getFacName() ~= "" then
    --   titleNameNode:setString(role:getTitleName())
    --   if titleColor then
    --     titleNameNode:setColor(titleColor)
    --   end
    -- else
    --   titleNameNode:setString(role:getTitleName())
    -- end

    titleNameNode:setString(role:getTitleName())
    if titleColor then
      titleNameNode:setColor(titleColor)
    end
  end

  -- local titleSpr = role:getTitleNode():getChildByTag(100)
  -- if titleSpr then
  --   if isShowFacName(role) then 
  --     titleSpr:setPosition(cc.p(0, 45))
  --   else
  --     titleSpr:setPosition(cc.p(0, 28))
  --   end
  -- end

  self:showShaName(role, MRoleStruct:getAttr(PLAYER_FACTIONID, role:getTag()))
  --self:setSignPos()
  self:changeFactionNameColor(role)

  self:resetPosForTop(role)
end

function RoleSprite:setVip_ex(role, vip)
end

function RoleSprite:setFaction_ex(role, factionId)
  log("setFaction_ex factionId = "..factionId)
  if (not role) or (role == G_ROLE_MAIN) then return end

  local isSameFaction = function(factionId)
    log("my factionId = "..require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
    return (factionId == require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID) and factionId ~= 0)
  end

  local nameNode = role:getDownNode()
  if nameNode then
    if isSameFaction(factionId) then
      log("setFaction_ex true")
      nameNode:removeAllChildren()
      local factionFlagBg = createSprite(nameNode, "res/layers/setting/2-2.png", cc.p(20, -100), cc.p(0.5, 0.5), nil, 0.6)
      factionFlagBg:setTag(300)
    else
      if nameNode:getChildByTag(300) then nameNode:removeChildByTag(300) end
    end
  end
end

function isShowFacName(role)
  -- local facNameNode = role:getFacNameBatchLabel()
  -- if facNameNode and facNameNode:getString() ~= "" then
  --   return true
  -- end

  if role:getFacName() and role:getFacName() ~= "" then
    return true
  end

  return false
end

function RoleSprite:setFactionName_ex(role, factionName, mustShowShaName)
  --log("setFaction_ex factionName = "..tostring(factionName))

  if factionName and string.len(factionName) > 0 then
    role:setFacName(factionName)
  else
    role:setFacName("")
  end

  local facNameNode = role:getFacNameBatchLabel()
  if facNameNode then
    if role:getFacName() ~= "" then
      facNameNode:setString("<"..role:getFacName()..">")
    else
      facNameNode:setString(role:getFacName())
    end
  end

  local titleSpr = role:getTitleNode():getChildByTag(100)
  if titleSpr then
    if isShowFacName(role) then 
      titleSpr:setPosition(cc.p(0, 45))
    else
      titleSpr:setPosition(cc.p(0, 28))
    end
  end

  self:showShaName(role, MRoleStruct:getAttr(PLAYER_FACTIONID, role:getTag()), mustShowShaName)
  self:setSignPos()
  self:changeFactionNameColor(role)

  self:resetPosForTop(role)
end

function RoleSprite:updateCornerSign_ex(c_type)
   log("updateCornerSign_ex c_type = "..c_type)
   if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.role_tab then
    for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
      local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")
      local role_flag
      if c_type == 1 then
      elseif c_type == 2 then
        log("test 2")
        role_flag = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID, v)
      end
      --log("role_item = "..tostring(role_item))
      --log("role_flag = "..tostring(role_flag))
      if role_item and role_flag then
        if role_item ~= G_ROLE_MAIN then
          G_ROLE_MAIN:setCornerSign_ex(role_item,c_type,role_flag)
        end
      end
    end
  end
end

function RoleSprite:setCornerSign_ex(role,c_type,flag)
  -- log("11111111111111111111 set role c_type = "..tostring(c_type))
  -- log("11111111111111111111 set role flag = "..tostring(flag))
  --dump(role == G_ROLE_MAIN)
  if not role then return end

  --自己的属性刷新时需要去刷新周围人的角标
  if role == G_ROLE_MAIN then
    self:updateCornerSign_ex(c_type)
    
    return
  end

  local signNode = role:getDownNode()
  if not signNode then return end
  if c_type == 1 then -- 同组
      local isTheSameTeam = function()
        --公平竞技厂不显示
        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
            return false
        end
        if G_TEAM_INFO.has_team then
          local name = role:getTheName()
          for i=1,G_TEAM_INFO.memCnt do
            if G_TEAM_INFO.team_data[i] and ( name == G_TEAM_INFO.team_data[i].name ) then
              return true
            end
          end
        end
        return false
      end
    if isTheSameTeam() then
      if signNode:getChildrenCount() == 0 then
        signNode:setLocalZOrder(1)
        local factionFlagBg = createSprite(signNode, "res/layers/setting/2-1.png", cc.p(25, -10), cc.p(0.5, 0.5), 2, 0.5)
        factionFlagBg:setTag(600)
      end
    else
      if signNode:getChildByTag(600) then signNode:removeChildByTag(600) end
    end
  elseif c_type == 2 then -- 同会 -- 同盟
    local my_facid = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
    --log("11111111111111111111 my_facid = "..tostring(my_facid))
    --log("11111111111111111111 flag = "..tostring(flag))
    if flag == 0 or my_facid == 0 then
       if signNode:getChildByTag(300) then signNode:removeChildByTag(300) end
       if signNode:getChildByTag(301) then signNode:removeChildByTag(301) end
       G_ROLE_MAIN:setCornerSign_ex(role,1)
    else

      if self:getFactionRelation(flag, 3) then
        if signNode:getChildByTag(300) then signNode:removeChildByTag(300) end
        if signNode:getChildByTag(301) then signNode:removeChildByTag(301) end
        signNode:setLocalZOrder(2)
        local factionFlagBg = createSprite(signNode, "res/layers/setting/2-2.png", cc.p(25, -10), cc.p(0.5, 0.5), 1, 0.5)
        factionFlagBg:setTag(300)
      elseif self:getFactionRelation(flag, 1) then
        if signNode:getChildByTag(300) then signNode:removeChildByTag(300) end
        if signNode:getChildByTag(301) then signNode:removeChildByTag(301) end
        signNode:setLocalZOrder(3)
        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 4101 then
          local nameLable = role:getNameBatchLabel()
          local factionFlagBg = createSprite(signNode, "res/layers/setting/2-4.png", cc.p(-nameLable:getContentSize().width/2, 100), cc.p(1, 0.5), nil, 0.7)
          factionFlagBg:setTag(301)
        else
          local factionFlagBg = createSprite(signNode, "res/layers/setting/2-3.png", cc.p(25, -10), cc.p(0.5, 0.5), 1, 0.5)
          factionFlagBg:setTag(301)
        end
      else
        if signNode:getChildByTag(300) then signNode:removeChildByTag(300) end
        if signNode:getChildByTag(301) then signNode:removeChildByTag(301) end
      end
    end
  end
end

--获取行会关系, type: 1、是否联盟,2、是否敌对,3、是否同帮
function RoleSprite:getFactionRelation(factionId, type)
  if factionId == 0 then return false end

  if type == 1 then
    if G_FACTION_INFO and G_FACTION_INFO.ally_fac_list then 
      for k,v in pairs(G_FACTION_INFO.ally_fac_list)do
        if factionId == v then
          return true
        end
      end
    end
    return false
  elseif type == 2 then
    if G_FACTION_INFO and G_FACTION_INFO.Hostile_fac_list then 
      for k,v in pairs(G_FACTION_INFO.Hostile_fac_list)do
        if factionId == v then
          return true
        end
      end
    end
    return false
  elseif type == 3 then
    local my_facid = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
    return factionId == my_facid
  end
  return false
end

function RoleSprite:updateCar_ex(m_flag)
  if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.role_tab then
    for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
      local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")
      local role_flag = require("src/layers/role/RoleStruct"):getAttr(PLAYER_TEAMID, v)
      if role_item and role_flag then
        if role_item ~= G_ROLE_MAIN then
          G_ROLE_MAIN:setCar_ex(role_item, role_flag)
        end
      end
    end
    for k,v in pairs(G_MAINSCENE.map_layer.monster_tab) do
      local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(v), "SpriteMonster")
      local role_flag = require("src/layers/role/RoleStruct"):getAttr(PLAYER_TEAMID, v)
      if role_item and role_flag and m_flag and m_flag == role_flag then
          G_ROLE_MAIN:setCar_ex(role_item, role_flag)
      end
    end
  end
end

function RoleSprite:setCar_ex(role, flag)
  local signNode = role:getTitleNode()
  if not signNode then return end
  if role == G_ROLE_MAIN then
    self:updateCar_ex(flag)
    return
  end
 
    local isTheSameTeam = function()
        if flag and flag == require("src/layers/role/RoleStruct"):getAttr(PLAYER_TEAMID) and flag ~= 0 and G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 2100 then
            return true
        end
        return false
    end

    if isTheSameTeam() then
        local nameLable = role:getNameBatchLabel()
        local isShowFlag = true
        if G_MAINSCENE and role:getType() < 20 then--小于20除了镖车就是宠物
          local monster_id = role:getMonsterId()
          if not ( monster_id >= 80000 and monster_id < 80005 ) then
            isShowFlag = false
          end
        end
        
        if isShowFlag then
            local factionFlagBg = createSprite(signNode, "res/component/flag/car.png", cc.p(-nameLable:getContentSize().width/2, -10), cc.p(1, 0.5), nil, 0.7)
            factionFlagBg:setTag(900)
        end
    else
        if signNode:getChildByTag(900) then signNode:removeChildByTag(900) end
    end
    G_MAINSCENE:QryMonsterNameColor(role:getTag())
end

function RoleSprite:setNameColor_ex(role, pk, isGray)
  local MRoleStruct = require "src/layers/role/RoleStruct"
 
  local white = 1
  local yellow = 2
  local red = 3
  local gray = 4
  local pkColorTab = {}
  pkColorTab[white] = {color = MColor.white}
  pkColorTab[yellow] = {pk = 1, color = MColor.name_yellow}
  pkColorTab[red] = {pk = 4, color = MColor.name_red}
  pkColorTab[gray] = {color = MColor.name_gray}

  role = tolua.cast(role, "SpritePlayer")
  local nameNode
  if role then
    nameNode = role:getNameBatchLabel()
  end

  if nameNode then
    if isGray then
      local rolePk = MRoleStruct:getAttr(PLAYER_PK, role:getTag()) or 0
      if rolePk < pkColorTab[red].pk then
        nameNode:setColor(pkColorTab[gray].color)
        self:changeFactionNameColor(role)
        return
      end
    end

    if pk >= pkColorTab[red].pk then
      nameNode:setColor(pkColorTab[red].color)
    elseif pk >= pkColorTab[yellow].pk then
      nameNode:setColor(pkColorTab[yellow].color)
    else
      nameNode:setColor(pkColorTab[white].color)
    end

  end
  self:changeFactionNameColor(role)
end

function RoleSprite:isHaveCarry(role)
  if role then
    local topNode = role:getTopNode()
    if topNode then
      local carryNode = topNode:getChildByTag(400)
      if carryNode then
        return true
      end
    end
  end
  return false
end

function RoleSprite:setCarry_ex(role, tab)
  --log("setCarry_ex")
  --tab = {{cout = 1, matId = 10001, time = os.time() + 20}}
  --dump(tab)
  role = tolua.cast(role, "SpritePlayer")
  local carryNode
  if role then
    local topNode = role:getTopNode()
    if topNode then
      carryNode = topNode:getChildByTag(400)
      if carryNode then
        removeFromParent(carryNode)
        carryNode = nil
        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.carry_owner_objid and G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] then
          G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] = nil
        end
      end

      if tab and #tab > 0 then
        carryNode = cc.Node:create()
        topNode:addChild(carryNode, 3, 400)

        local titleParentNode  = role:getTitleNode()
        local titleSpr = titleParentNode:getChildByTag(100)
        if titleSpr then
          carryNode:setPosition(cc.p(0, 100 + titleSpr:getContentSize().height * titleSpr:getScale()))
        else
          carryNode:setPosition(cc.p(0, 100))
        end

        if isShowFacName(role) then
          carryNode:setPosition(carryNode:getPositionX(), carryNode:getPositionY()+20)
        end
      end

    end
  else
    return
  end

  local addAction = function(node, time)
    --log("addAction")
    local createNoticeAction = function()
      --log("createNoticeAction")
      local timeLeft = time - os.time()
      local off = 1
      local scale = 1

      if timeLeft < 10 then
        off = 4
        scale = 1.4
      elseif timeLeft < 20 then
        off = 2
        scale = 1.2
      elseif timeLeft < 30 then
        off = 1
        scale = 1.1
      else
        --log("time left error time = ")
        return
      end

      --node:setScale(0.5 * scale)

      local offX = math.random(-off, off)
      local offY = math.random(-off, off)
      --log("offX = "..offX.." offY = "..offY.." timeLeft = "..timeLeft)
      local go = cc.MoveBy:create(0.1, cc.p(offX, offY))
      local back = go:reverse()
      --log("addAction end")
      return cc.Sequence:create(go, back)
    end
   
    startTimerAction(node, 0.2, true, function() 
        --log("test abc 111111")
        local action = createNoticeAction()
        if action then
          node:runAction(action) 
        end 
        --log("test abc 2222222")
      end)
    --log("addAction end")
  end

  local addIcon = function(parent, tab)
    --log("addIcon")
    local paddingX = 45
    local paddingY = 45
    local lineNumber = 4
    if #tab < lineNumber then
      lineNumber = #tab
    end
    local lineWidth = paddingX * (lineNumber - 1)
    local x, y = -(lineWidth / 2), 40
    --dump(tab)
    for i,v in ipairs(tab) do
      local posX = x + ((i - 1) % lineNumber) * paddingX
      local posY = y + (math.ceil(i / lineNumber) - 1) * paddingY

      if parent then
        local Mprop = require( "src/layers/bag/prop" )
        local iconNode = Mprop.new({protoId = v.matId})
        iconNode:setScale(0.5)
        parent:addChild(iconNode)
        iconNode:setPosition(cc.p(posX, posY))
        local carry_tab = {[1197]=true,[1198]=true,[1199]=true,[10001]=true,
                           [6200052]=true,[6200053]=true,[6200054]=true,[6200055]=true,[6200056]=true,[6200057]=true,[6200058]=true}
        if carry_tab[v.matId] and  role ~= G_ROLE_MAIN and G_MAINSCENE and G_MAINSCENE.map_layer then
          if v.matId == 10001 then
            G_MAINSCENE.map_layer.carry_owner_objid = {}
          end          
          G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] = true
        end
        addAction(iconNode, v.time)
      end
      --log("addIcon end")
    end
  end

  --挖到矿石结晶加提示
  role.MineTabData = role.MineTabData or {}
  if #role.MineTabData < #tab and #tab ~= 0 and role.isHoe and role == G_ROLE_MAIN then
    G_ROLE_MAIN:MineTipsTimer(role, false, true)
  end
  role.MineTabData = tab

  if carryNode and tab and #tab > 0 then
    addIcon(carryNode, tab)
    if role == G_ROLE_MAIN then
      self:setSignState(false)
    end
  else
    if role == G_ROLE_MAIN then
      --dump(tab)
      self:setSignState(true)
    end
  end

  self:resetPosForTop(role)
  --log("setCarry_ex end")
end

function RoleSprite:setBanner(role, flg)
    local topNode = role:getTopNode()
    local bannerSpr = nil
    if tonumber(flg) == 0 then
        bannerSpr = topNode:getChildByTag(701)
        if bannerSpr then
            removeFromParent(bannerSpr)
        end

        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.banner_owner_objid and G_MAINSCENE.map_layer.banner_owner_objid[role:getTag()] then
          G_MAINSCENE.map_layer.banner_owner_objid[role:getTag()] = nil
        end

        if role == G_ROLE_MAIN then
          self:setSignState(true)
        end
    else
        bannerSpr = topNode:getChildByTag(701)
        if not bannerSpr then
            bannerSpr = createSprite(topNode, "res/empire/23.png", cc.p(0, 130), cc.p(0.5, 0.5), 1, 1)
            bannerSpr:setTag(701)
            bannerSpr:setScale(0.8)

            local titleParentNode  = role:getTitleNode()
            local titleSpr = titleParentNode:getChildByTag(100)
            if titleSpr then
              bannerSpr:setPosition(cc.p(0, 150 + titleSpr:getContentSize().height * titleSpr:getScale()))
            else
              bannerSpr:setPosition(cc.p(0, 150))
            end        

            if isShowFacName(role) then
              bannerSpr:setPosition(bannerSpr:getPositionX(), bannerSpr:getPositionY()+20)
            end    
        end
        
        if role ~= G_ROLE_MAIN and G_MAINSCENE and G_MAINSCENE.map_layer then
          G_MAINSCENE.map_layer.banner_owner_objid[role:getTag()] = true
        end

        if role == G_ROLE_MAIN then
          self:setSignState(false)
        end
    end

    self:resetPosForTop(role)
end

function RoleSprite:setMine(role, tab)
  log("setMine")

  local addIcon = function(parent, tab)
    local paddingX = 45
    local paddingY = 45
    local lineNumber = 4
    if #tab < lineNumber then
      lineNumber = #tab
    end
    local lineWidth = paddingX * (lineNumber - 1)
    local x, y = -(lineWidth / 2), 40
    for i,v in ipairs(tab) do
      if i > 2 then
        break
      end
      local posX = x + ((i - 1) % lineNumber) * paddingX
      local posY = y + (math.ceil(i / lineNumber) - 1) * paddingY

      if parent then
        local Mprop = require( "src/layers/bag/prop" )
        local iconNode = Mprop.new({protoId = v.matId})
        iconNode:setScale(0.5)
        parent:addChild(iconNode, 2)
        iconNode:setPosition(cc.p(posX, posY))
        local carry_tab = {[1197]=true,[1198]=true,[1199]=true,[10001]=true,
                           [6200052]=true,[6200053]=true,[6200054]=true,[6200055]=true,[6200056]=true,[6200057]=true,[6200058]=true}
        if carry_tab[v.matId] and  role ~= G_ROLE_MAIN and G_MAINSCENE and G_MAINSCENE.map_layer then
          if v.matId == 10001 then
            G_MAINSCENE.map_layer.carry_owner_objid = {}
          end
          G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] = true
        end
      end
    end
  end
  role = tolua.cast(role, "SpritePlayer")
  local mineNode = nil
  if role then
    local nameNode = role:getTopNode()
    if nameNode then
      mineNode = nameNode:getChildByTag(700)
      if mineNode == nil then
        mineNode = cc.Node:create()
        nameNode:addChild(mineNode, 1)
        mineNode:setTag(700)
        mineNode:setPosition(cc.p(0, 25))

        local titleSpr = role:getTitleNode():getChildByTag(100)
        if titleSpr then
          mineNode:setPosition(cc.p(0, 25 + titleSpr:getContentSize().height * titleSpr:getScale()))
        else
          mineNode:setPosition(cc.p(0, 25))
        end           
      end
    else
       log("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! setMine noNameNode")
    end
  else
    log("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! setMine role Error")
    return
  end

  if type(tab) == "string" then
    tab = unserialize(tab)
  end

  if mineNode and tab then
    mineNode:removeAllChildren()
    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.carry_owner_objid and G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] then
      G_MAINSCENE.map_layer.carry_owner_objid[role:getTag()] = nil
    end
    addIcon(mineNode, tab)
  end
  if role == G_ROLE_MAIN then
    G_ROLE_MAIN.mineTab = tab
  end  
end

function RoleSprite:addArrow()
  local effLayer = self:getChildByTag(904)
  if not effLayer then
    effLayer = cc.Node:create()
    self:addChild( effLayer , - 1 )
    setNodeAttr( effLayer , cc.p( self:getContentSize().width/2 , 0 ) , cc.p( 0.5 , 0.5 ) )
    local eff = Effects:create(false)
    effLayer:addChild( eff)
    effLayer:setTag(904)
    eff:setTag(904)
    self.arrowEffect = eff    
    self.arrowEffectNode = effLayer
    self.curEffNum = nil
  end
end

function RoleSprite:changeArrowRot(rote)
  self:addArrow()
  if self:getChildByTag(904) and self:getChildByTag(904):getChildByTag(904) then
    -- local realRote = rote % 360
    -- local dir = realRote / 90
    -- local isLeft,isBottom = false, false
    -- local effNum = 0
    -- if dir == 1 or dir == 2 or dir == 3 or dir == 0 then
    --   if dir == 1 then effNum  = 4 end
    --   if dir == 2 then isBottom = true effNum = 0 end
    --   if dir == 3 then isLeft  = true effNum = 4 end
    --   if dir == 0 then effNum = 0 end
    -- else
    --   effNum = (realRote % 90 )/ (90 /4)
    --   if math.floor(effNum + 0.5) > math.floor(effNum) then
    --     effNum = math.floor(effNum + 1)
    --   else
    --     effNum = math.floor(effNum)
    --   end      

    --   if dir > 1 and dir < 2 then
    --     isBottom = true
    --     effNum = 4 - effNum
    --   elseif dir > 2 and dir < 3 then
    --     isLeft = true
    --     isBottom = true
    --   elseif dir > 3 and dir < 4 then
    --     isLeft = true
    --     effNum = 4 - effNum
    --   end
    -- end

    local isLeft = (rote % 360) > 180 and true or false
    rote = isLeft and (rote % 360 - 180) or (rote % 360)
    local effNum = rote/ (90 /4)
    if math.floor(effNum + 0.5) > math.floor(effNum) then
      effNum = math.floor(effNum + 1)
    else
      effNum = math.floor(effNum)
    end
    if isLeft then
      effNum = 8 - effNum
    end

    --self.arrowEffect:playActionData("transfor",15,2,-1)
    --print("changeArrowRot .. effNum=" ..effNum..",isLeft=" .. (isLeft and "true" or "false") .. ",isBottom" ..(isBottom and "true" or "false").. ",rote="  ..rote..",realRote ="..(realRote % 90 ))
    if not self.curEffNum or self.curEffNum ~= effNum then
      self.arrowEffect:playActionData("arrow/"..effNum, 3, 0.8, -1)
      self.curEffNum = effNum
    end
    self.arrowEffect:setFlippedX(isLeft)
    --self.arrowEffect:setFlippedY(true)
    self.arrowEffectNode:setVisible(self.arrowEffIsVisible and self.arrowIsVisible)
  end
end

function RoleSprite:setArrowNodeVisible(isvisable)
  self.arrowIsVisible = isvisable
  if self:getChildByTag(904) then 
    self:getChildByTag(904):setVisible(self.arrowEffIsVisible and self.arrowIsVisible)
  end
end

function RoleSprite:getArrowisVisiable( ... )
  return self.arrowIsVisible or false
end

function RoleSprite:setArrowEffVisible(isvisable)
  self.arrowEffIsVisible = isvisable
  if self:getChildByTag(904) then 
    self:getChildByTag(904):setVisible(self.arrowEffIsVisible and self.arrowIsVisible)
    --print("arrowIsVisible" .. (self.arrowEffIsVisible and self.arrowIsVisible and "true" or "false"))
  end
end

function RoleSprite:removeArrowDir()
  local node = self:getChildByTag(904)
  if node then 
    removeFromParent(node)
    self.arrowEffect = nil
  end
end

function RoleSprite:updateHodeInfo(isHide, index)
  if not G_SHAWAR_DATA.transfor then
    return
  end

  local BtnNode 
  for k,v in pairs(G_SHAWAR_DATA.transfor) do
    if v.index == index then
      BtnNode = v.btnNode
    end
  end

  if BtnNode then
    if not isHide then
        self.shaWarHoldIndex = index
    else
        if self.shaWarHoldIndex == index then
            self.shaWarHoldIndex = 0
        end
    end
    if BtnNode.shaExitBtn then
      BtnNode.shaExitBtn:setVisible(not isHide)
    end
  end
end

function RoleSprite:showShaName(role, factionId, mustShowShaName)
  if role then
    local tempDef = G_SHAWAR_DATA.startInfo.DefenseID
    --local name_label = role:getNameBatchLabel()
    local facNameLabel = role:getFacNameBatchLabel()
    local strName = role:getTheName()
    if facNameLabel and strName ~= "" then
      --print("showShaName :" ,factionId, tempDef)
      if (factionId ~= nil and tempDef ~= nil and tempDef ~= 0 and factionId == tempDef) or mustShowShaName then
        facNameLabel:setString("<"..role:getFacName()..">".."("..game.getStrByKey("shaWar_name") .. ")")
      else
        if role:getFacName() ~= "" then
          facNameLabel:setString("<"..role:getFacName()..">")
        end
      end
    end   
  end
end

function RoleSprite:MineTipsTimer(role, begain, isHave)
  --local tipCfg = {7, 8, 9, 10}
  if role.mineTimer then
    role:stopAction(role.mineTimer)
    role.mineTimer = nil
  end  

  role.MineTabData = role.MineTabData or {}
  if isHave then
    local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 32000 , 7 })
    if msg_item  then  
      TIPS( {str = msg_item.msg,type = 1} ) 
    end
  elseif begain and #role.MineTabData == 0 then
    role.mineTimer = startTimerAction(role, 15, true, function()
      math.randomseed(os.time())
      math.random()
      local num = math.random(0, 2)
      local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 32000 , 8 + num })
      if msg_item  then  
        TIPS( {str = msg_item.msg,type = 1} ) 
      end
    end)
  end
end

function RoleSprite:resetPosForTop(role)
  if role == nil then
    return
  end

  local titleNameNode = role:getTitleNameBatchLabel()
  local facNameNode = role:getFacNameBatchLabel()
  local titleSpr = role:getTitleNode():getChildByTag(100)
  local bannerSpr = role:getTopNode():getChildByTag(701)
  local mineNode = role:getTopNode():getChildByTag(700)
  local carryNode = role:getTopNode():getChildByTag(400)
  local holdNode = role:getTopNode():getChildByName("shaWarRoleHoldBtn")

  if titleNameNode then
    if isShowSpecialTitleName(role) then
      titleNameNode:setPosition(titleNameNode:getPositionX(), titleNameNode:getPositionY()+20)
    end    
    if isShowFacName(role) then
      titleNameNode:setPosition(cc.p(titleNameNode:getPositionX(), facNameNode:getPositionY() + 20))
    else
      titleNameNode:setPosition(cc.p(titleNameNode:getPositionX(), facNameNode:getPositionY()))
    end 
  end

  if titleSpr and titleSpr:isVisible() then
    local titlePos = cc.p(0, 28)
    if isShowFacName(role) then
        titlePos = cc.p(titlePos.x, titlePos.y + 20)
    end  

    if isShowSpecialTitleName(role) then
        titlePos = cc.p(titlePos.x, titlePos.y + 20)
    end    
    
    titleSpr:setPosition(titlePos)
  end

  if bannerSpr then
    if titleSpr and titleSpr:isVisible() then
      bannerSpr:setPosition(cc.p(0, 150 + titleSpr:getContentSize().height * titleSpr:getScale()))
    else
      bannerSpr:setPosition(cc.p(0, 150))
    end

    if isShowSpecialTitleName(role) then
      bannerSpr:setPosition(bannerSpr:getPositionX(), bannerSpr:getPositionY()+20)
    end

    if isShowFacName(role) then
      bannerSpr:setPosition(bannerSpr:getPositionX(), bannerSpr:getPositionY()+20)
    end   
  end

  if carryNode then
    if titleSpr and titleSpr:isVisible() then
      carryNode:setPosition(cc.p(0, 110 + titleSpr:getContentSize().height * titleSpr:getScale()))
    else
      carryNode:setPosition(cc.p(0, 110))
    end

    if isShowSpecialTitleName(role) then
      carryNode:setPosition(carryNode:getPositionX(), carryNode:getPositionY()+20)
    end

    if isShowFacName(role) then
      carryNode:setPosition(carryNode:getPositionX(), carryNode:getPositionY()+20)
    end  
  end

  if holdNode then
    if titleSpr and titleSpr:isVisible() then
      holdNode:setPosition(cc.p(0, 160 + titleSpr:getContentSize().height * titleSpr:getScale()))
    else
      holdNode:setPosition(cc.p(0, 160))
    end

    if isShowSpecialTitleName(role) then
      holdNode:setPosition(holdNode:getPositionX(), holdNode:getPositionY()+20)
    end

    if isShowFacName(role) then
      holdNode:setPosition(holdNode:getPositionX(), holdNode:getPositionY()+20)
    end      
  end

  self:setSignPos()
end

function RoleSprite:changeFactionNameColor(role)
  if role == nil then return end
  local facNameNode = role:getFacNameBatchLabel()
  if facNameNode then
    local nameNode = role:getNameBatchLabel()
    if nameNode then
      facNameNode:setColor(nameNode:getColor())
    end
  end
end

function RoleSprite:showShaWarHoldBtn(role, flg)
  local key = "shaWarRoleHoldBtn"

  if role and role ~= G_ROLE_MAIN then
    local topNode = role:getTopNode()
    if topNode then
      local tempNode = topNode:getChildByName(key)
      if flg then
        if not tempNode then
          tempNode = cc.Node:create()
          tempNode:setName(key)
          topNode:addChild(tempNode, 3)

          local func = function()
            if G_MAINSCENE and G_MAINSCENE.map_layer then
              G_MAINSCENE.map_layer:touchRoleFunc(role)
            end
            btn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.6, cc.p(0, 5)), cc.MoveTo:create(0.6, cc.p(0, -5)) ) ))
          end
          local btn = createMenuItem(tempNode, "res/empire/shaWar/holdBtn.png", cc.p(0, 0), func)
          btn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.6, cc.p(0, 5)), cc.MoveTo:create(0.6, cc.p(0, -5)) ) ))
        end
      else
        if tempNode then
          removeFromParent(tempNode)
        end
      end
    end
  end

  self:resetPosForTop(role)
end

return RoleSprite