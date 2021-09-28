
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
            pos= cc.p("@3","@4"),  order     = -50,
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = -60,
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
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "walk",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3("@10","@11",0),
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
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@7",times="@5",},},},},
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
        {delay = {time = 0.2,},},
    },


jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        {delay = {time = 0.2,},},
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
             params = {"clip_f","wd640.jpg","320","640","1"},},
    },



    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -200),
        },
    },



    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "fudi.jpg",
			parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920, 0),
            order = -99,
            file  = "fudi.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scale = 0.8,
            pos   = cc.p(1600, 400),
            order = -90,
            file  = "bf.png",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
    },



    -- {
    --     load = {tmpl = "mod22",
    --         params = {"hero_zj","_lead_","-400","100","0.12","clip_1"},},
    -- },

    -- {
    --     load = {tmpl = "mod21",
    --         params = {"hero_lby","hero_nvzhu","1800","0","0.17","clip_1"},},
    -- },

    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情


	{
        music = {file = "jianghu1.mp3",},
    },






     -- {
     --     load = {tmpl = "jp1",
     --         params = {"hero_zj","0.6","300","0","6"},},
     -- },


    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-400,100),    order     = 49,
            file = "_run_",    animation = "pao",
            scale = 0.16,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "zjue",sync = true,what = {move = {
                   time = 0.5,by = cc.p(300,0),},},},},


    {remove = { model = {"zjue", }, },},


    {
        load = {tmpl = "mod22",
            params = {"hero_zj","_lead_","-100","100","0.16","clip_1"},},
    },







	{
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },



    {remove = { model = {"hero_zj", }, },},

    {
        load = {tmpl = "mod21",
            params = {"hero_zj","_lead_","-100","100","0.16","clip_1"},},
    },

    {
        delay = {time = 0.5,},
    },

    {remove = { model = {"hero_zj", }, },},

    {
        load = {tmpl = "mod22",
            params = {"hero_zj","_lead_","-100","100","0.16","clip_1"},},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },
     {
         load = {tmpl = "talk1",
             params = {"zj",TR("咦？这是什么地方，我怎么到这里来了？"),14},},
     },






     {
         load = {tmpl = "talk0",
             params = {"zj",TR("啊！我怎么变成了这个样子？"),15},},
     },
     -- {
     --     load = {tmpl = "talk2",
     --         params = {"zj",TR("对了！是那个圆盘！"),"1002.mp3"},},
     -- },

    -- {
    --     model = {
    --         tag   = "yp",
    --         type  = DEF.PIC,
    --         scale = 0.7,
    --         pos   = cc.p(240, -10),
    --         order = -40,
    --         file  = "yupan.png",
    --         parent="clip_1",
    --     },
    -- },

     -- {
     --     load = {tmpl = "move2",
     --         params = {"yp","yp.png","神秘玉盘"},},
     -- },


     -- {
     --     load = {tmpl = "talk",
     --         params = {"yp",TR("玄封之印，玉女为师")},},
     -- },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("前面的那是？"),16},},
     },

    -- {
    --     load = {tmpl = "out3",
    --         params = {"zj","yp"},},
    -- },

    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","1.2","1","-1400","0"},},
     },


    {delay={time=0.5},},

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.4","1","300","0"},},
     },






    -- {
    --     action = {
    --         tag   = "clip_1",
    --         sync = true,

    --         what = {
    --             spawn = {
    --                 rotate = {
    --                     by = cc.vec3(0, 5, 0),
    --                     time = 1.5,
    --                 },
    --             },
    --         },

    --     },},


    --  {
    --      load = {tmpl = "jttb",
    --          params = {"clip_1","1.5","1","-600","0"},},
    --  },

    -- {
    --     action = {
    --         tag   = "clip_1",
    --         sync = true,
    --         -- anchor= cc.p(0,0,0),
    --         what = {
    --             rotate = {
    --                 by = cc.vec3(0, 5, 0),
    --                 time = 1.5,
    --             },
    --         },

    --     },},




    -- {
    --     load = {tmpl = "mod22",
    --         params = {"hero_zj","_lead_","940","100","0.16","clip_1"},},
    -- },

     -- {
     --     load = {tmpl = "jp1",
     --         params = {"hero_zj","0.4","160","0","4"},},
     -- },



    {remove = { model = {"hero_zj", }, },},




    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(700,100),    order     = 49,
            file = "_run_",    animation = "pao",
            scale = 0.16,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "zjue",sync = false,what = {move = {
                   time = 0.7,by = cc.p(400,0),},},},},

    {delay={time=0.5},},


     {
         load = {tmpl = "jttb",
             params = {"clip_1","0.8","1","-400","0"},},
     },

    {delay={time=0.2},},

     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_1","1.5","1","-300","0"},},
     -- },




    {remove = { model = {"zjue", }, },},


    {
        load = {tmpl = "mod22",
            params = {"hero_zj","_lead_","1100","100","0.16","clip_1"},},
    },

    {delay={time=0.3},},

     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_1","0.6","1","-200","0"},},
     -- },












	{
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },


     {
         load = {tmpl = "talk",
             params = {"zj",TR("哇！这么漂亮的小姐姐！"),17},},
     },

    {
        delay = {time = 0.4,},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.8","3","-3300","-1000"},},
     },

    {
        delay = {time = 0.2,},
    },





    {
        sound = {file = "biwu.mp3",sync=false,},
    },
     {
         load = {tmpl = "mod3111",
             params = {"effect_ui_ruwutupo","0.5","1600","330","clip_1"},},
     },

    --     {remove = { model = {"map3", }, },},

    -- {
    --     model = {
    --         tag   = "map3",
    --         type  = DEF.PIC,
    --         scale = 0.8,
    --         pos   = cc.p(1600, 380),
    --         order = -90,
    --         file  = "jc.png",
    --         parent= "clip_1",
    --         rotation3D=cc.vec3(0,180,0),
    --     },
    -- },


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(1595,345),    order   = 49,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.095,   parent = "clip_1", speed = 2, opacity=0,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {delay={time=0.5},},


    {
        model = {
            tag = "lbyi",
            speed = 0,
        },
    },

        {remove = { model = {"map3", }, },},

    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scale = 0.8,
            pos   = cc.p(1600, 380),
            order = -90,
            file  = "bt.png",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
    },

    {action = {tag  = "lbyi", sync = true,what = {fadein = {time = 0,},},},},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","6","-9500","-2700"},},
     },

    {
        model = {
            tag = "lbyi",
            speed = 0.25,
        },
    },

    {delay={time=0.5},},

    {
        model = {
            tag = "lbyi",
            speed = 0.75,
        },
    },




    -- {
    --     load = {tmpl = "mod21",
    --         params = {"hero_lby","hero_nvzhu","1800","0","0.17","clip_1"},},
    -- },

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("白衣女子")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("——你是谁？"),250},},
     },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","1.2","1","-1600","-300"},},
     },

        {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(1595,345),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.095,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {delay={time=0.5},},

    {
        model = {
            tag = "lbyi",
            speed = 0,
        },
    },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

     {action = {
             tag  = "lbyi",sync = true,what = {
             spawn = {{move = {time = 0.2,by= cc.p(0, 105), },},},
            },},},


        {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(1595,450),    order     = 50,
            file = "hero_nvzhu",    animation = "poss",
            scale = 0.095,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.5","1","400","0"},},
     },

    {action = {tag  = "lbyi",sync = true,what ={ spawn={{scale= {time = 1,to = 0.17,},},
    {bezier = {time = 1,to = cc.p(1300,100),
                                 control={cc.p(1600,450),cc.p(1300,450),}
    },},},
    },},},

        {remove = { model = {"lbyi", }, },},


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(1300,100),    order   = 49,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.17,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


-- --剑光特效预留




     {
         load = {tmpl = "talk",
             params = {"lby",TR("本门禁地，擅入者——死！"),251},},
     },

--      {
--          load = {tmpl = "talk1",
--              params = {"zj",TR("（当时那把剑离我的喉咙只有0．01公分，但机智如我，一句话便让那把剑的女主人…… ）"),"1008.mp3"},},
--      },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("美女姐姐饶命啊！ "),18},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("嗯？你身上有青灵玉盘！"),252},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("啊？你说的是这个吗？ "),19},},
     },

    -- {
    --     load = {tmpl = "out2",
    --         params = {"lby"},},
    -- },

    --  {
    --      load = {tmpl = "move2",
    --          params = {"yp","yp.png","青灵玉牌"},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"yp",TR("……")},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"zj",TR("你这破玩意儿还翻脸不认人了！ "),"1011.mp3"},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"yp",TR("自作自受……")},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"zj",TR("你他喵的，信不信小爷把你摔个稀巴烂！ "),"1011.mp3"},},
    --  },

    -- {
    --     load = {tmpl = "out2",
    --         params = {"yp"},},
    -- },


    {
        sound = {file = "biwu.mp3",sync=false,},
    },
     {
         load = {tmpl = "mod3111",
             params = {"effect_ui_shenbingqjinjie","0.5","1200","250","clip_1"},},
     },



    {delay={time=0.15},},

    {
        model = {
            tag       = "xiangzi",     type      = DEF.FIGURE,
            pos= cc.p(1205,270),     order     = 101,
            file      = "effect_jinlun",         animation = "animation",
            scale     = 0.18,         loop      = true,
            endRlease = false,         parent = "clip_1", speed=2,
        },},


    {
        model = { tag = "yupan",type  = DEF.PIC,
                  file  = "yp.png",order = 100,scale=0.2,
                  pos   = cc.p(1200, 250),parent = "clip_1",rotation3D=cc.vec3(30,30,0),},
    },



-- --剑光特效预留





     -- {
     --     load = {tmpl = "talk",
     --         params = {"zj",TR("师父饶命啊！我真的没有骗你！ "),"1011.mp3"},},
     -- },

     -- {
     --     load = {tmpl = "move2",
     --         params = {"lby","lby.png","白衣女子"},},
     -- },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("这是——青灵玉盘，是它把你送到这里来的，以后你便是我的弟子，我会好好教导你的！"),253},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("美女师父！这青灵玉盘究竟是什么来历？ "),20},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("具体来历我也不清楚，不过它是一件可以收集天下武功的奇物！"),254},},
     },



     {
         load = {tmpl = "talk",
             params = {"zj",TR("哇！这么神奇呢！那我们接下来要做什么呢？ "),21},},
     },




     -- {
     --     load = {tmpl = "talk1",
     --         params = {"lby",TR("是的，祖师曾经历五代十国之乱，当时华夏罹难，祖师有感于人世凋零，万物遗逝，于是立下誓愿……"),"1020.mp3"},},
     -- },


     -- {
     --     load = {tmpl = "talk2",
     --         params = {"lby",TR("——收集天下武功秘籍，为后世弦继绝学！"),"1021.mp3"},},
     -- },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"zj",TR("哦哦！那我们要收集哪些武功呢？ "),"1022.mp3"},},
     -- },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("终南山，古墓，玉女心经——"),255},},
     },









-- --青灵玉牌特效预留






     -- {
     --     load = {tmpl = "talk",
     --         params = {"zj",TR("哇！这么多厉害的武功，我要修炼一阳指！ "),"1011.mp3"},},
     -- },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"lby",TR("你的资质，现在更适合修炼这门武功——"),"1005.mp3"},},
     -- },


     -- {
     --     load = {tmpl = "talk",
     --         params = {"zj",TR("我——靠——野球拳！！！你这不是在逗我吧！？ "),"1011.mp3"},},
     -- },

    -- {
    --     load = {tmpl = "out2",
    --         params = {"lby"},},
    -- },

    --  {
    --      load = {tmpl = "move2",
    --          params = {"yp","yp.png","青灵玉牌"},},
    --  },




-- --青灵玉牌特效预留





     -- {
     --     load = {tmpl = "talk",
     --         params = {"yp",TR("欠缺秘籍：玉女心经，拥有者：小龙女")},},
     -- },


     {
         load = {tmpl = "talk",
             params = {"zj",TR("古墓？玉女心经？那岂不是有小龙女！（不知道小龙女与我家师父比起来哪个更美） "),22},},
     },






    {
        delay = {time = 0.5,},
    },
    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },
        -- {delay = {time = 5,},},

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
