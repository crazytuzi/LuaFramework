
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 28, text = "@1",
            -- maxWidth = 600,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =0.4,
        },},
    {delay = {time = 0.8,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },


jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放

        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},

    },


qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------
    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },


    {
        delay = {time = 0.1,},
    },

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },

    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1920, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj11","ll_22.png","1","-500","300","30","clip_1","0","-210","0"},},
    },
    {
        load = {tmpl = "modbj2",
            params = {"bj12","ui_effect_suanming","0.8","-480","280","28","clip_1","0","-180","0","0.5"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ybhui","hero_yangbuhui","-590","270","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"wxwen","hero_wuxiuwen","-650","250","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"hsnv","hero_huangshannv","-480","430","0.04","clip_1","20"},},
    },





    {
        load = {tmpl = "modbj2",
            params = {"bj141","ui_effect_xiaonvwawa","1.2","-540","360","48","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"hbweng","hero_huqingniu","0","260","0.115","clip_1","20"},},
    },


    {
        load = {tmpl = "mod21",
            params = {"nmxing","hero_nimoxing","400","280","0.10","clip_1","20"},},
    },




    {
        load = {tmpl = "modbj2",
            params = {"bj22","ui_effect_datiege","0.8","480","380","10","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"zzliu","hero_zhuziliu","620","280","0.1","clip_1","20"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"gfu","hero_guofu","320","-240","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"gplu","hero_guopolu","220","-240","0.16","clip_1","90"},},
    },






    {
        load = {tmpl = "modbj1",
            params = {"bj31","ll_15.png","0.7","-150","-180","95","clip_1","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj35","ui_effect_chifan_a","1","50","360","98","bj31","0","0","0","1"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj36","ui_effect_chifan_b","1","100","400","-94","bj31","0","0","0","1"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"zcong","hero_zhucong","-350","-270","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lyjiao","hero_luyoujiao","-700","-230","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ydtian","hero_yangdingtian","-1050","200","0.14","clip_1","40"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"zasheng","hero_zhangasheng","-1150","180","0.14","clip_1","40"},},
    },



    {   model = {
            tag  = "zslwang1",     type  = DEF.FIGURE,
            pos= cc.p(-860,200),    order     = 40,
            file = "hero_zishanlongwang",    animation = "daiji",
            scale = 0.13,   parent = "clip_1", speed = 0.3,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zslwang2",     type  = DEF.FIGURE,
            pos= cc.p(-910,195),    order     = 45,
            file = "hero_zishanlongwang",    animation = "yun",
            scale = 0.122,   parent = "clip_1", speed = 0.05,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","1800","-200"},},
     },

     {   model = {
            tag  = "mnci",     type  = DEF.FIGURE,
            pos= cc.p(-1725,200),    order     = 40,
            file = "hero_munianci",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-2250,0),    order     = 42,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        load = {tmpl = "mod21",
            params = {"oyke","hero_ouyangke","-1550","0","0.15","clip_1","41"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ysjling","hero_yinsuojinling","-1750","0","0.155","clip_1","41"},},
    },

    {
        music = {file = "jianghu2.mp3",},
    },

     {
         load = {tmpl = "zm",
             params = {TR("只记得那日，眼前光华流转，"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("你被青灵玉盘带入了奇异的空间，"),"850"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("物换星移，时光倒还，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("你发现自己置身于一间酒馆中，"),"700"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("而那位将你送来的粉衣少女——"),"650"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("竟然也在这里？！"),"600"},},
     },



    {delay = {time = 2,},},

    {remove = { model = {"900", "850", "750", "700", "650","600",},},},



    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情

    {
        music = {file = "battle2.mp3",},
    },

    {
        delay = {time = 0.3,},
    },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","0.8","1325","-200"},},
     },


    {
        delay = {time = 0.5,},
    },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("嘿嘿，小美人，乖乖从了我吧，哥哥会好好心疼你的。"),"1183.mp3"},},
     },


     {
         load = {tmpl = "move1",
             params = {"ysjl","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ysjl",TR("走开……你走开……"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"ysjl","oyk"},},
    },

       {remove = { model = {"text-board", }, },},


    {
        delay = {time = 0.2,},
    },


    {remove = { model = {"oyke", }, },},

     {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-1550,0),    order     = 42,
            file = "hero_ouyangke",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.1,},
    },

        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 1,to = cc.p(-1800,0),},},},},

    {
        delay = {time = 0.1,},
    },


    {remove = { model = {"ysjling", }, },},

    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(-1750,0),    order     = 42,
            file = "hero_yinsuojinling",    animation = "zou",
            scale = 0.155,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "ysjling",sync = false,what = {move = {
                   time = 1,to = cc.p(-2000,0),},},},},

    {
        delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","0.8","1595","-200"},},
     },

    {
        delay = {time = 1.2,},
    },


    {remove = { model = {"oyke", }, },},

    {
        load = {tmpl = "mod21",
            params = {"oyke","hero_ouyangke","-1800","0","0.15","clip_1","42"},},
    },

    {remove = { model = {"ysjling", }, },},

    {
        load = {tmpl = "mod22",
            params = {"ysjling","hero_yinsuojinling","-2000","0","0.155","clip_1","42"},},
    },

    {
        delay = {time = 0.1,},
    },


    {remove = { model = {"mnci", }, },},

     {   model = {
            tag  = "mnci",     type  = DEF.FIGURE,
            pos= cc.p(-1725,200),    order     = 40,
            file = "hero_munianci",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"mnc","mnc.png",TR("穆念慈")},},
     },

     {
         load = {tmpl = "talk",
             params = {"mnc",TR("欧阳克，你这禽兽，快放了这位姑娘！"),"1183.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("小美人，不要急，等哥哥先办了她，再来安慰你。"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"mnc"},},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("（怎么那个粉衣姑娘也在？！之前不可一世，怎么现在柔如羔羊，任狼宰割？）"),"1183.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("原来是你？！快说，为什么把我送来这里？"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"oyk",},},
    },

    {remove = { model = {"ysjling", }, },},

    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(-2000,0),    order     = 42,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.155,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "move2",
             params = {"ysjl","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ysjl",TR("以后……告诉你……先帮我……"),"1183.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("哼！欧阳克，又是你这坏蛋，看我今天不杀了你！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","ysjl"},},
    },

       {remove = { model = {"text-board", }, },},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"zjue", }, },},



    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-2250,0),    order     = 42,
            file = "_lead_",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-1600,0),
                                 control={cc.p(-2250,100),cc.p(-2000,200),}
    },},},
    },},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","0.8","1150","-200"},},
     },

    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"oyke", }, },},

    {
        sound = {file = "hero_ouyangke_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 42,
            file = "hero_ouyangke",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "oyke",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-1300,0),
                                 control={cc.p(-1800,0),cc.p(-1500,400),}
    },},},
    },},},

    {
       delay = {time = 1.5,},
    },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-1600,0),    order     = 42,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"oyke", }, },},

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-1300,0),    order     = 42,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

   {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("你是何人？我与我家娘子亲热，与你何干？"),"1183.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"hr","hr.png",TR("黄蓉")},},
     },

     {
         load = {tmpl = "talk",
             params = {"hr",TR("欧阳克，你这好色鬼，又在调戏良家？"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"hr","oyk"},},
    },

       {remove = { model = {"text-board", }, },},

    {
       delay = {time = 0.2,},
    },

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-1850,350),    order     = 40,
            file = "hero_huangrong",    animation = "daiji",
            scale = 0.135,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "hrong",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.135,},},
    {bezier = {time = 0.4,to = cc.p(-1550,150),
                                 control={cc.p(-1850,350),cc.p(-1600,550),}
    },},},
    },},},


    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-1800,200),    order     = 42,
            file = "hero_yangkang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "ykang",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.4,to = cc.p(-1475,0),
                                 control={cc.p(-1800,200),cc.p(-1600,400),}
    },},},
    },},},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-1850,50),    order     = 43,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.155,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "gjing",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.4,to = cc.p(-1550,-150),
                                 control={cc.p(-1850,50),cc.p(-1600,250),}
    },},},
    },},},

    {remove = { model = {"mnci", }, },},

     {   model = {
            tag  = "mnci",     type  = DEF.FIGURE,
            pos= cc.p(-1725,200),    order     = 40,
            file = "hero_munianci",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

   {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("蓉儿啊，你终于肯出来了！冤枉啊，要不是你对我无情，我又何必另寻新欢啊。"),"1183.mp3"},},
     },


     {
         load = {tmpl = "move1",
             params = {"hr","hr.png",TR("黄蓉")},},
     },

     {
         load = {tmpl = "talk",
             params = {"hr",TR("没羞没躁，靖哥哥快帮我教训他！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"hr","hr"},},
    },

     {
         load = {tmpl = "move1",
             params = {"yk","yk.png",TR("杨康")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"yk",TR("何必与他废话，杀了便是！"),"1183.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"yk",TR("胆敢调戏我家念慈，受死吧！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"yk","oyk"},},
    },


    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", }, },},

    {
       delay = {time = 0.1,},
    },


    {remove = { model = {"ykang", }, },},


    {
        sound = {file = "hero_yangkang_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-1475,0),    order     = 42,
            file = "hero_yangkang",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1.4, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "ykang",sync = false,what = {move = {
                   time = 0.5,to = cc.p(-1570,0),},},},},

    {
       delay = {time = 0.7,},
    },

    {remove = { model = {"oyke", }, },},

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-1300,0),    order     = 43,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.155,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 1.15,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.3","0.8","1025","-200"},},
     },


    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"oyke", }, },},

    {
        sound = {file = "bsxy_fail.mp3",loop = false, sync = false,},
    },

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-1200,0),    order     = 43,
            file = "hero_ouyangke",    animation = "yun",
            scale = 0.155,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.6,to = cc.p(-975,0),},},},},


    {remove = { model = {"ykang", }, },},

    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-1450,0),    order     = 42,
            file = "hero_yangkang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 1,},
    },

    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-700,300),    order     = 44,
            file = "hero_qiuqianchi",    animation = "daiji",
            scale = 0.16,   parent = "clip_1",sync = false,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "qqchi",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-1200,0),
                                 control={cc.p(-700,300),cc.p(-1000,400),}
    },},},
    },},},

    {
       delay = {time = 0.8,},
    },

   {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"qqc","qqc.png",TR("神秘老妪")},},
     },

     {
         load = {tmpl = "talk",
             params = {"qqc",TR("他的小命我收了，汝等小辈速速退散！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"qqc",},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", }, },},


    {
       delay = {time = 0.3,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.3","1.2","1425","-200"},},
     },

    {remove = { model = {"qqchi", }, },},

    {
        sound = {file = "hero_qiuqianchi_nuji.mp3",sync=false,},
    },

    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-1200,0),    order     = 42,
            file = "hero_qiuqianchi",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=255,
            loop = false,   endRlease = false,  speed=1.2, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "qqchi1",     type  = DEF.FIGURE,
            pos= cc.p(-1200,-100),    order     = 41,
            file = "hero_qiuqianchi",    animation = "nuji",
            scale = 0.16,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = false,  speed=1.2, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "qqchi2",     type  = DEF.FIGURE,
            pos= cc.p(-1200,100),    order     = 43,
            file = "hero_qiuqianchi",    animation = "nuji",
            scale = 0.162,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = false,  speed=1.2, rotation3D=cc.vec3(0,180,0),
        },},


    {
        model = {
            tag       = "guangxiao",     type      = DEF.FIGURE,
            pos= cc.p(-1200,0),     order     = 40,
            file      = "effect_wg_xuanmingzhang",         animation = "animation",
            scale     = 1.1,        loop      = false,opacity=200,
            endRlease = false,         parent = "clip_1", speed=0.9,rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.3,},
    },

        {action = {tag  = "qqchi1",sync = false,what = {fadeout = {time = "0.8",},},},},
        {action = {tag  = "qqchi2",sync = false,what = {fadeout = {time = "0.8",},},},},

    {
       delay = {time = 0.35,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","0.8","1150","-200"},},
     },

    {
       delay = {time = 0.1,},
    },

    {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

    {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

        {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

        {
        load = {
            tmpl = "shake",
        },
    },

    {remove = { model = {"hrong", }, },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-1550,150),    order     = 40,
            file = "hero_huangrong",    animation = "aida",
            scale = 0.135,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "hrong",sync = false,what = {move = {
                   time = 0.3,to = cc.p(-1650,150),},},},},


    {remove = { model = {"ykang", }, },},

    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-1475,0),    order     = 42,
            file = "hero_yangkang",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "ykang",sync = false,what = {move = {
                   time = 0.3,to = cc.p(-1575,0),},},},},


    {remove = { model = {"gjing", }, },},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-1550,-150),    order     = 43,
            file = "hero_guojing",    animation = "aida",
            scale = 0.155,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "gjing",sync = false,what = {move = {
                   time = 0.3,to = cc.p(-1650,-150),},},},},

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-1600,0),    order     = 42,
            file = "_lead_",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "zjue",sync = false,what = {move = {
                   time = 0.3,to = cc.p(-1700,0),},},},},

    {
       delay = {time = 0.4},
    },


    {remove = { model = {"hrong", }, },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-1650,150),    order     = 40,
            file = "hero_huangrong",    animation = "yun",
            scale = 0.135,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


    {remove = { model = {"ykang", }, },},

    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-1575,0),    order     = 42,
            file = "hero_yangkang",    animation = "yun",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"gjing", }, },},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-1650,-150),    order     = 43,
            file = "hero_guojing",    animation = "yun",
            scale = 0.155,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-1700,0),    order     = 42,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-1200,0),    order     = 42,
            file = "hero_qiuqianchi",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", opacity=255,
            loop = false,   endRlease = false,  speed=1.2, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 1.2,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
       delay = {time = 0.1,},
    },
}