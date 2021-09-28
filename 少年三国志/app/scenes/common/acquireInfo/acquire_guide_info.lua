--acquire_guide_info.lua


record_acquire_guide_info = {}

record_acquire_guide_info.step_id = 0
record_acquire_guide_info.step_desc = ""
record_acquire_guide_info.scene_name = "" --所处场景  
record_acquire_guide_info.layer_name = "" --所处界面  
record_acquire_guide_info.next_step = 0 --跳转至步骤  
record_acquire_guide_info.x = 0 --基点x坐标  
record_acquire_guide_info.y = 0 --基点y坐标  
record_acquire_guide_info.width = 0 --宽度  
record_acquire_guide_info.height = 0 --高度  
record_acquire_guide_info.hooker_delay = 0 --监控延迟时间 
record_acquire_guide_info.click_widget = "" --需点击控件名  
record_acquire_guide_info.scale_value = 100
record_acquire_guide_info.click_param1 = 0 --点击参数1  
record_acquire_guide_info.prepare_data = 0 --预准备数据  


acquire_guide_info =  {
	_data = {
		[1] = {1, "", "DungeonGateScene", "DungeonMapLayer", 0, 0, 0, 0, 0, 400, "stage_%d", 20, 2, 0 },
		[2] = {2, "", "DungeonGateScene", "DungeonEnterGateLayer", 0, 0, 0, 0, 0, 300, "Button_Challenge", 100, 0, 0 },

		[3] = {10, "", "StoryDungeonMainScene", "StoryDungeonLayer", 0, 0, 0, 0, 0, 400, "Button_Field%d", 100, 1, 0 },
		[4] = {11, "", "StoryDungeonListScene", "PlayingLayer", 0, 250,-269,140,74, 0, "Panel_List", 100, 2, 0 },

    [5] = {20, "", "ShopScene", "ShopLayer", 0, 0, 0, 0, 0, 600, "Panel_proplistview", 100, 2, 0 },

    [6] = {30, "", "ShopScene", "ShopLayer", 0, 0, 0, 0, 0, 400, "Button_liangpin", 100, 0, 0 },

    [7] = {40, "", "ShopScene", "ShopLayer", 0, 0, 0, 0, 0, 400, "Button_jipin", 100, 0, 0 },

    [8] = {50, "", "HeroScene", "heroArray", 0, 0, 0, 0, 0, 800, "Button_strength", 100, 0, 0 },

    [9] = {60, "", "HeroFosterScene", "HeroFosterLayer", 0, 0, 0, 0, 0, 600, "", 100, 1, 0 },

    [10] = {80, "", "EquipmentMainScene", "EquipmentListLayer", 0, 0, 0, 0, 0, 600, "", 100, 1, 0 },

    [11] = {100, "", "TreasureMainScene", "TreasureListLayer", 0, 0, 0, 0, 0, 600, "", 100, 1, 0 },

    [20] = {200, "", "DungeonGateScene", "DungeonMapLayer", 0, 0, 0, 0, 0, 400, "stage_%d", 20, 2, 0 },
    [21] = {201, "", "DungeonGateScene", "DungeonEnterGateLayer", 0, 0, 0, 0, 0, 300, "Button_Seckill", 100, 0, 0 },

    [24] = {210, "", "HardDungeonGateScene", "HardDungeonMapLayer", 0, 0, 0, 0, 0, 400, "stage_%d", 20, 2, 0 },
    [25] = {211, "", "HardDungeonGateScene", "HardDungeonEnterGateLayer", 0, 0, 0, 0, 0, 300, "Button_Challenge", 100, 0, 0 },

    [30] = {215, "", "HardDungeonGateScene", "HardDungeonMapLayer", 0, 0, 0, 0, 0, 400, "stage_%d", 20, 2, 0 },
    [31] = {216, "", "HardDungeonGateScene", "HardDungeonEnterGateLayer", 0, 0, 0, 0, 0, 300, "Button_Seckill", 100, 0, 0 },

    [35] = {350, "", "HeroFosterScene", "HeroFosterLayer", 0, 0, 0, 0, 0, 600, "", 100, 1, 0 },

    [50] = {500, "", "HeroScene", "heroArray", 0, 0, 0, 0, 0, 600, "Button_back_2", 100, 1, 0 },
	}
}


local __index_step_id = {
    [1] = 1,
    [2] = 2,
    [10] = 3,
    [11] = 4,
    [20] = 5,
    [30] = 6,
    [40] = 7,
    [50] = 8,
    [60] = 9,
    [80] = 10,
    [100] = 11,
    [200] = 20,
    [201] = 21,
    [210] = 24,
    [211] = 25,
    [215] = 30,
    [216] = 31,
    [350] = 35,
    [500] = 50,
    }


local __key_map = {
  step_id = 1,
  step_desc = 2,
  scene_name = 3,
  layer_name = 4,
  next_step = 5,
  x = 6,
  y = 7,
  width = 8,
  height = 9,
  hooker_delay = 10,
  click_widget = 11,
  scale_value = 12,
  click_param1 = 13,
  prepare_data = 14,

}



local m = { 
    __index = function(t, k) 
        assert(__key_map[k], "cannot find " .. k .. " in record_acquire_guide_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function acquire_guide_info.getLength()
    return #acquire_guide_info._data
end



function acquire_guide_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_newplay_guide_info
function acquire_guide_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = acquire_guide_info._data[index]}, m)
end

---
--@return @class record_newplay_guide_info
function acquire_guide_info.get(step_id)
    
    return acquire_guide_info.indexOf(__index_step_id[step_id])
        
end
