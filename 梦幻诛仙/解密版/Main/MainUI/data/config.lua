local config = {}
config.SceneId = {
  Default = 0,
  Fight = 1,
  SoloDungeon = 2,
  TeamDungeon = 3,
  JueZhanJiuXiao = 4,
  Convoy = 5,
  PhantomCave = 6,
  GangBattle = 7,
  SXZB = 8,
  TXHW = 9,
  QMHW = 10,
  WEDDING = 11,
  BANQUET = 12,
  HULA = 13,
  INTERACTIVE_TASK = 14,
  ZHUXIANJIANZHEN = 15,
  GANG_DUNGEON = 16,
  CROSS_BATTLE = 17,
  POINTS_RACE = 18,
  GANGCROSSBATTLE = 19,
  SINGLEBATTLE = 20,
  CHESS = 21,
  PETBATTLE = 22,
  TREASUREHUNT = 23,
  AAGR_HALL = 24,
  AAGR_ARENA = 25
}
config.ComponentId = {
  RoleHead = 1,
  MapRadar = 2,
  MainMenu = 3,
  Chat = 4,
  RightSubPanel = 5,
  RoleExp = 6,
  TaskTrace = 7,
  PetHead = 8,
  TopActivity = 9,
  Buff = 10,
  TopButtonGroup = 11,
  LeftButtonGroup = 12,
  HeadPortraitGroup = 13,
  BackToMain = 14,
  NewFunction = 15,
  TopButtonGroupInActivity = 16,
  Camera = 17
}
config.EventBinding = {
  [config.SceneId.Fight] = {
    enter = {
      ModuleId.FIGHT,
      gmodule.notifyId.Fight.ENTER_FIGHT
    },
    leave = {
      ModuleId.FIGHT,
      gmodule.notifyId.Fight.LEAVE_FIGHT
    }
  },
  [config.SceneId.SoloDungeon] = {
    enter = {
      ModuleId.DUNGEON,
      gmodule.notifyId.Dungeon.ENTER_SOLO_DUNGEON
    },
    leave = {
      ModuleId.DUNGEON,
      gmodule.notifyId.Dungeon.LEAVE_SOLO_DUNGEON
    }
  },
  [config.SceneId.TeamDungeon] = {
    enter = {
      ModuleId.DUNGEON,
      gmodule.notifyId.Dungeon.ENTER_TEAM_DUNGEON
    },
    leave = {
      ModuleId.DUNGEON,
      gmodule.notifyId.Dungeon.LEAVE_TEAM_DUNGEON
    }
  },
  [config.SceneId.JueZhanJiuXiao] = {
    enter = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_JZJX_Enter
    },
    leave = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_JZJX_Leave
    }
  },
  [config.SceneId.Convoy] = {
    enter = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_Convoy_START
    },
    leave = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_Convoy_END
    }
  },
  [config.SceneId.PhantomCave] = {
    enter = {
      ModuleId.PHANTOMCAVE,
      gmodule.notifyId.PhantomCave.START_ACTIVITY
    },
    leave = {
      ModuleId.PHANTOMCAVE,
      gmodule.notifyId.PhantomCave.LEAVE_ACTIVITY
    }
  },
  [config.SceneId.GangBattle] = {
    enter = {
      ModuleId.GANG,
      gmodule.notifyId.Gang.ENTER_GANG_BATTLE_MAP
    },
    leave = {
      ModuleId.GANG,
      gmodule.notifyId.Gang.LEAVE_GANG_BATTLE_MAP
    }
  },
  [config.SceneId.GANGCROSSBATTLE] = {
    enter = {
      ModuleId.GANG_CROSS,
      gmodule.notifyId.GangCross.ENTER_GANG_BATTLE_MAP
    },
    leave = {
      ModuleId.GANG_CROSS,
      gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP
    }
  },
  [config.SceneId.SXZB] = {
    enter = {
      ModuleId.LEADER_BATTLE,
      gmodule.notifyId.PVP.ENTER_LEADER_BATTLE
    },
    leave = {
      ModuleId.LEADER_BATTLE,
      gmodule.notifyId.PVP.LEAVE_LEADER_BATTLE
    }
  },
  [config.SceneId.TXHW] = {
    enter = {
      ModuleId.PK,
      gmodule.notifyId.PK.ENTER_TXHW
    },
    leave = {
      ModuleId.PK,
      gmodule.notifyId.PK.LEAVE_TXHW
    }
  },
  [config.SceneId.QMHW] = {
    enter = {
      ModuleId.QIMAI_HUIWU,
      gmodule.notifyId.Qimai.ENTER_QMHW
    },
    leave = {
      ModuleId.QIMAI_HUIWU,
      gmodule.notifyId.Qimai.LEAVE_QMHW
    }
  },
  [config.SceneId.WEDDING] = {
    enter = {
      ModuleId.MARRIAGE,
      gmodule.notifyId.Marriage.EnterMassWedding
    },
    leave = {
      ModuleId.MARRIAGE,
      gmodule.notifyId.Marriage.LeaveMassWedding
    }
  },
  [config.SceneId.BANQUET] = {
    enter = {
      ModuleId.BANQUET,
      gmodule.notifyId.Banquet.ENTER_BANQUET
    },
    leave = {
      ModuleId.BANQUET,
      gmodule.notifyId.Banquet.LEAVE_BANQUET
    }
  },
  [config.SceneId.HULA] = {
    enter = {
      ModuleId.DOUDOU_CLEAR,
      gmodule.notifyId.Hula.ENTER_HULA
    },
    leave = {
      ModuleId.DOUDOU_CLEAR,
      gmodule.notifyId.Hula.QUIT_HULA
    }
  },
  [config.SceneId.INTERACTIVE_TASK] = {
    enter = {
      ModuleId.INTERACTIVE_TASK,
      gmodule.notifyId.InteractiveTask.ENTER_TASK_MAP
    },
    leave = {
      ModuleId.INTERACTIVE_TASK,
      gmodule.notifyId.InteractiveTask.LEAVE_TASK_MAP
    }
  },
  [config.SceneId.ZHUXIANJIANZHEN] = {
    enter = {
      ModuleId.SOARING,
      gmodule.notifyId.Soaring.ENTER_ZHUXIANJIANZHEN
    },
    leave = {
      ModuleId.SOARING,
      gmodule.notifyId.Soaring.QUIT_ZHUXIANJIANZHEN
    }
  },
  [config.SceneId.GANG_DUNGEON] = {
    enter = {
      ModuleId.GANG_DUNGEON,
      gmodule.notifyId.GangDungeon.EnterGangDungeon
    },
    leave = {
      ModuleId.GANG_DUNGEON,
      gmodule.notifyId.GangDungeon.LeaveGangDungeon
    }
  },
  [config.SceneId.CROSS_BATTLE] = {
    enter = {
      ModuleId.CROSS_BATTLE,
      gmodule.notifyId.CrossBattle.Cross_Battle_Enter_Game_Scene
    },
    leave = {
      ModuleId.CROSS_BATTLE,
      gmodule.notifyId.CrossBattle.Cross_Battle_Leave_Game_Scene
    }
  },
  [config.SceneId.POINTS_RACE] = {
    enter = {
      ModuleId.CROSS_BATTLE,
      gmodule.notifyId.CrossBattle.CrossBattlePointsRace.Cross_Battle_Enter_POINTS_RACE
    },
    leave = {
      ModuleId.CROSS_BATTLE,
      gmodule.notifyId.CrossBattle.CrossBattlePointsRace.Cross_Battle_Leave_POINTS_RACE
    }
  },
  [config.SceneId.CHESS] = {
    enter = {
      ModuleId.CHESS,
      gmodule.notifyId.CHESS.EnterChess
    },
    leave = {
      ModuleId.CHESS,
      gmodule.notifyId.CHESS.LeaveChess
    }
  },
  [config.SceneId.SINGLEBATTLE] = {
    enter = {
      ModuleId.CTF,
      gmodule.notifyId.CTF.EnterSingleBattle
    },
    leave = {
      ModuleId.CTF,
      gmodule.notifyId.CTF.LeaveSingleBattle
    }
  },
  [config.SceneId.PETBATTLE] = {
    enter = {
      ModuleId.FIGHT,
      gmodule.notifyId.Fight.ENTER_PET_BATTLE
    },
    leave = {
      ModuleId.FIGHT,
      gmodule.notifyId.Fight.LEAVE_PET_BATTLE
    }
  },
  [config.SceneId.TREASUREHUNT] = {
    enter = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_Treasure_Hunt_Enter
    },
    leave = {
      ModuleId.ACTIVITY,
      gmodule.notifyId.activity.Activity_Treasure_Hunt_Leave
    }
  },
  [config.SceneId.AAGR_HALL] = {
    enter = {
      ModuleId.AAGR,
      gmodule.notifyId.Aagr.AAGR_ENTER_HALL
    },
    leave = {
      ModuleId.AAGR,
      gmodule.notifyId.Aagr.AAGR_LEAVE_HALL
    }
  },
  [config.SceneId.AAGR_ARENA] = {
    enter = {
      ModuleId.AAGR,
      gmodule.notifyId.Aagr.AAGR_ENTER_ARENA
    },
    leave = {
      ModuleId.AAGR,
      gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA
    }
  }
}
config.DisplayableBinding = {
  [config.ComponentId.RoleHead] = {
    undisplay = {
      config.SceneId.CHESS,
      config.SceneId.PETBATTLE,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.PetHead] = {
    undisplay = {
      config.SceneId.CHESS,
      config.SceneId.PETBATTLE,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.HeadPortraitGroup] = {
    undisplay = {
      config.SceneId.CHESS,
      config.SceneId.PETBATTLE,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.Buff] = {
    undisplay = {
      config.SceneId.CHESS,
      config.SceneId.PETBATTLE,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.MapRadar] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.CHESS,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.RightSubPanel] = {
    undisplay = {
      config.SceneId.SoloDungeon,
      config.SceneId.Convoy,
      config.SceneId.SXZB,
      config.SceneId.ZHUXIANJIANZHEN,
      config.SceneId.CHESS,
      config.SceneId.SINGLEBATTLE,
      config.SceneId.TREASUREHUNT,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.MainMenu] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.CHESS,
      config.SceneId.AAGR_ARENA
    }
  },
  [config.ComponentId.Chat] = {
    undisplay = {
      config.SceneId.CHESS
    }
  },
  [config.ComponentId.TopButtonGroup] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.SoloDungeon,
      config.SceneId.TeamDungeon,
      config.SceneId.JueZhanJiuXiao,
      config.SceneId.Convoy,
      config.SceneId.PhantomCave,
      config.SceneId.GangBattle,
      config.SceneId.SXZB,
      config.SceneId.TXHW,
      config.SceneId.QMHW,
      config.SceneId.BANQUET,
      config.SceneId.WEDDING,
      config.SceneId.HULA,
      config.SceneId.INTERACTIVE_TASK,
      config.SceneId.ZHUXIANJIANZHEN,
      config.SceneId.GANG_DUNGEON,
      config.SceneId.CROSS_BATTLE,
      config.SceneId.POINTS_RACE,
      config.SceneId.GANGCROSSBATTLE,
      config.SceneId.SINGLEBATTLE,
      config.SceneId.CHESS,
      config.SceneId.TREASUREHUNT,
      config.SceneId.AAGR_ARENA,
      config.SceneId.AAGR_HALL
    }
  },
  [config.ComponentId.TopButtonGroupInActivity] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.BANQUET,
      config.SceneId.AAGR_ARENA,
      config.SceneId.AAGR_HALL
    }
  },
  [config.ComponentId.LeftButtonGroup] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.ZHUXIANJIANZHEN,
      config.SceneId.POINTS_RACE,
      config.SceneId.CHESS,
      config.SceneId.SINGLEBATTLE,
      config.SceneId.AAGR_ARENA,
      config.SceneId.AAGR_HALL
    }
  },
  [config.ComponentId.NewFunction] = {
    undisplay = {
      config.SceneId.Fight,
      config.SceneId.JueZhanJiuXiao,
      config.SceneId.Convoy,
      config.SceneId.PhantomCave,
      config.SceneId.GangBattle,
      config.SceneId.SXZB,
      config.SceneId.TXHW,
      config.SceneId.QMHW,
      config.SceneId.BANQUET,
      config.SceneId.WEDDING,
      config.SceneId.HULA,
      config.SceneId.ZHUXIANJIANZHEN,
      config.SceneId.GANG_DUNGEON,
      config.SceneId.CROSS_BATTLE,
      config.SceneId.POINTS_RACE,
      config.SceneId.CHESS,
      config.SceneId.GANGCROSSBATTLE,
      config.SceneId.SINGLEBATTLE,
      config.SceneId.AAGR_ARENA,
      config.SceneId.AAGR_HALL
    }
  },
  [config.ComponentId.Camera] = {
    undisplay = {
      config.SceneId.GANGCROSSBATTLE,
      config.SceneId.SINGLEBATTLE,
      config.SceneId.PETBATTLE
    }
  }
}
return config
