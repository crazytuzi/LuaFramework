--
-- Author: LaoY
-- Date: 2018-07-12 20:24:01
--

LoginConst = LoginConst or {}

--职业配置
LoginConst.CareerConfig = {
    { name = "Dragon Slayer",
      baseId = 40001,
      wingId = 40001,
      position = { x = 0.439, y = 0.35, z = -3.04 },
      hidePosition = { x = 100, y = 0.35, z = -3.04 },
      bodyEffect = {
          "rfoot/fx_40001",
          "root/40001",
          --"root/effect_male_attack04 (1)",
          --"root/suduxian",
          --"root/suduxian (2)",
          --"root/suduxian (3)",
          --"root/chongjibo (3)",
          --"root/05_diyidaoguang",
          --"root/05_diyidaoguang (1)",
          --"root/05_diyidaoguang (2)",
          --"root/dilie",
          --"root/effect_male_attack04 (1)",
      },
      actionArray = {
          ["show2"] = { "root/effect_male_40001_suduxian" },
          ["show3"] = { "root/effect_male_40001" },
      },
      defaultActions = { "idle2" },
      showActions = { "show1", "show3", "idle1" }, --
      norShowActions = { "show", "idle" },
      ---SHOW动作序列延时时间
      showDelay = 0,
      showDelayEffect = "",
      career = 1,
      head = "img_role_head_1",
      gender = 1,
      genderTxt = "Male",
      OccupationIcon = "Occupation_Icon_1",
      OccupationTxt = "Occupation_Txt_1",
      CareerIcon = "role_img_1",
      Desc = "　　Let the Power of Thunder awaken today!\nBe the light of life and the source of power!",
      DescOutlineColor = "#2278a9",
      SoundId = 62
    },
    { name = "Elf Knight",
      baseId = 40002,
      wingId = 40002,
      position = { x = 0.407, y = 0.36, z = -3.188 },
      hidePosition = { x = 100, y = 0.36, z = -3.188 },
      bodyEffect = {
          "Bip001 L Hand/lizi_tuowei",
          "Bip001 R Hand/lizi_tuowei (1)",
          "Bip001 R Hand/glow",
          "root/eff_nvzhu",
      },
      wingEffect = {
          "root_wing/Dummy001/Bone020/p_lizi",
          "root_wing/Dummy001/Bone015/p_lizi (1)",
      },
      actionArray = {

      },
      defaultActions = { "idle2" },
      showActions = { "show", "idle" },
      norShowActions = { "show", "idle" },
      showDelay = 0,
      showDelayEffect = "effect_feixiangqianfang",
      career = 2,
      head = "img_role_head_2",
      gender = 2,
      genderTxt = "Saintess",
      OccupationIcon = "Occupation_Icon_2",
      OccupationTxt = "Occupation_Txt_2",
      CareerIcon = "role_img_2",
      Desc = "　　Get lost in dreams,\nand chase illusions for an answer.",
      DescOutlineColor = "#985b8d",
      SoundId = 63
    },
    -- {name = "剑士",career = 3},
}

function LoginConst:GetConfigById(id)
    for _, v in ipairs(self.CareerConfig) do
        if (v.baseId == id) then
            return v
        end
    end
    return LoginConst.CareerConfig[1]
end

function LoginConst:GetDefaultAction(config)
    return { animations = config.defaultActions, isLoop = true,
             default = config.defaultActions[#config.defaultActions], delay = 0 }
end