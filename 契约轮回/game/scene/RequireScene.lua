--
-- @Author: chk
-- @Date:   2018-07-20 10:00:44
--
require('game.scene.map.MapManager')
require('game.scene.SceneManager')
require('game.scene.SceneConfigManager')
require('game.scene.BuffManager')

require('game.scene.operation.OperationManager')
require('game.scene.operation.OperationMove')

-- 场景基本配置
require('game.scene.SceneConstant')
--场景事件
require('game.scene.SceneEvent')

--场景特效配置
--只能放在这里,不能迁移
require("game.config.client.SceneEffectConfig" )

--场景人物
require('game.scene.object.SceneObject')
require('game.scene.object.SceneObjectText')
require("game/scene/object/RoleText");
require("game/scene/object/MonsterText");
require('game.scene.object.AdvanceDungeonItem')
require('game.scene.object.ShadowImage')
require('game.scene.object.CountDownText')
require('game.scene.object.Role')
require('game.scene.object.MainRole')
require('game.scene.object.Monster')
require('game.scene.object.Boss')
require('game.scene.object.Npc')
require('game.scene.object.Door')
require('game.scene.object.Drop')
require('game.scene.object.JumpPoint')
require('game.scene.object.Effect')
require("game.scene.object.Robot")
require("game.scene.object.MachineArmor")

-- 附庸对象
require('game.scene.object.DependObjcet')
require('game.scene.object.DependStaticObject')
require('game.scene.object.Fairy')
require('game.scene.object.Talisman')
require('game.scene.object.Pet')
require('game.scene.object.Magic')
require('game.scene.object.God')
require('game.scene.object.Wing')
require('game.scene.object.Weapon')
require('game.scene.object.Mount')
require('game.scene.object.Head')
require('game.scene.object.Hand')
require("game.scene.object.MagicArray")

require('game.scene.object.SceneObjTitle')

-- 场景数据
require('game.scene.data.ObjectData')
require('game.scene.data.SceneInfoData')
require('game.scene.data.RoleData')
require('game.scene.data.MainRoleData')
require('game.scene.data.MonsterData')
require('game.scene.data.NpcData')
require('game.scene.data.DoorData')
require('game.scene.data.DropData')
require('game.scene.data.JumpPointData')
require('game.scene.data.EffectData')
require("game.scene.data.RobotData")
require("game.scene.data.MachineArmorData")

require('game.scene.data.Buff')

require('game.scene.object.SceneObjTitle')