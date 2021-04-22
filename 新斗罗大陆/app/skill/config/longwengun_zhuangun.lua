local boss_shenhaimojing_juguai_jifei = 
{
  CLASS = "composite.QSBSequence",
  ARGS = 
  {
    {
      CLASS = "composite.QSBParallel",
      ARGS = 
      {
        {
          CLASS = "action.QSBPlayAnimation",
        },
        {
          CLASS = "composite.QSBSequence",
          ARGS = 
          {
            {
              CLASS = "action.QSBDelayTime",
              OPTIONS = {delay_time = 4 / 24 },
            }, 
            {
                CLASS = "action.QSBPlaySound",
                OPTIONS = {sound_id ="xiaowu_lxrc_sf",is_loop = true},
            },
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_time = 48 / 24 },
            },
            {
                CLASS = "action.QSBStopSound",
                OPTIONS = {sound_id ="xiaowu_lxrc_sf"},
            },
          },
        },
        {
          CLASS = "composite.QSBSequence",
          ARGS = 
          {
            {
              CLASS = "action.QSBDelayTime",
              OPTIONS = {delay_time = 0.5},
            },
            {
              CLASS = "action.QSBHitTarget",
            },
            {
              CLASS = "action.QSBDragActor",
              OPTIONS = {pos_type = "self" , pos = {x = 100,y = 0} , duration = 0.35, flip_with_actor = true },
            },
          },
        },
      },
    }, 
    {
      CLASS = "action.QSBAttackFinish",
    },
  },    
}
return boss_shenhaimojing_juguai_jifei