
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
            size   = 25, text = "@1",
            maxWidth = 500,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =1.2,
        },},
    {delay = {time = 0.5,},},
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
             },},},},},


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
         music = {file = "backgroundmusic3.mp3",},
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
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(0,-800),
            order = -100,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(0,-600),
            order = -101,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map4",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920, 0),
            order = -99,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map5",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(1920,-800),
            order = -100,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map6",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(1920,-600),
            order = -101,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map7",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(3840, 0),
            order = -99,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map8",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(3840,-800),
            order = -100,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map9",
            type  = DEF.PIC,
            scaleX = 1, scaleY=2,
            pos   = cc.p(3840,-600),
            order = -101,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },



    {
        delay = {time = 0.1,},
    },

	{
        music = {file = "jianghu2.mp3",},
    },


     {
         load = {tmpl = "zm",
             params = {TR("杨过一路追寻，"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("却丝毫没有小龙女的音讯。"),"850"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("古墓中温馨恬淡的回忆，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("让杨过愈加思念小龙女，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("回想起自己这半生孤苦，"),"700"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("杨过不禁悲从中来……"),"650"},},
     },


    {delay = {time = 2.1,},},

    {remove = { model = {"900", "850", "800","750", "700", "650",}, },},




     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","-200","-200"},},
     },


    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(1700,-200),    order     = 50,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},


----正式剧情


    -- {
    --     delay = {time = 0.1,},
    -- },


    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(200,0),    order     = 50,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "yguo",sync = false,what = {move = {
                   time = 2.6,by = cc.p(800,-400),},},},},
    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


    -- {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 2,to = 0.16,},},
    -- {bezier = {time = 2,to = cc.p(-300,-300),
    --                              control={cc.p(-800,0),cc.p(-550,100),}
    -- },},},
    -- },},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.6","0.8","-900","100"},},
     },
    {
        delay = {time = 2,},
    },


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(1000,-400),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑！你究竟在哪里啊！你真的不要过儿了吗？我——我活在这个世上究竟还有什么意义！"),"1132.mp3"},},
     },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.18,},},
    {bezier = {time = 0.2,to = cc.p(1300,-300),
                                 control={cc.p(1700,-200),cc.p(1400,300),}
    },},},
    },},},



     {
         load = {tmpl = "move2",
             params = {"hqg","hqg.png",TR("洪七公")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hqg",TR("喂！臭小子，你吵什么吵啊？大风大雪，你一个人到这里来做什么？"),"1133.mp3"},},
     },



     {
         load = {tmpl = "talk",
             params = {"yg",TR("我！？一个人！？……哈哈哈！我……生来命苦，活在这世上……根本就是多余的！"),"1134.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"hqg",TR("混账！我老乞丐活了几十年了，还没活够呢，你年纪轻轻的就想着要去死！"),"1135.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("我爹为人所害，我娘客死异乡，现在……连最疼爱我的姑姑也离我而去，你说我活在这个世上还有什么意思！"),"1136.mp3"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"hqg",TR("看你相貌堂堂，却活得这么糊涂！这么混账！身负血海深仇却不思还报，至亲离你而去……"),"1137.mp3"},},
     },

     {
         load = {tmpl = "talk0",
             params = {"hqg",TR("你却只会在这里自怨自艾，要死要活！"),"1138.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"hqg",TR("你的父母，你的姑姑，疼你爱你，到头来，你除了在这里大喊大叫，你又能为他们做什么？"),"1139.mp3"},},
     },




       {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(1000,-400),    order     = 50,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "yguo",sync = true,what = {move = {
                   time = 0.5,by = cc.p(100,100),},},},},


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(1100,-300),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},


    {
        model = {
            tag   = "shitou",
            type  = DEF.PIC,
            scaleX = 0.92, scaleY=0.3,
            pos   = cc.p(2660,225),
            order = 40,
            file  = "bw_11301.png",
            parent= "clip_1",
            rotation3D=cc.vec3(45,0,0),
        },
    },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("我……？你说的很对，我不能死，我还要替我爹爹报仇，我还要找到姑姑……"),"1140.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"hqg",TR("哈哈哈！这就对了嘛！啊~~~哈~~~，刚才我老叫化睡得好好，让你给吵醒了，我现在要回去睡上三天三夜！"),"1141.mp3"},},
     },







     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.8","-2000","-200"},},
     },
       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(1300,-300),    order     = 50,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.18,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2650,160),
                                 control={cc.p(1300,-300),cc.p(2000,500),}
    },},},
    },},},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "yguo",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2500,160),
                                 control={cc.p(1100,-300),cc.p(2000,500),}
    },},},
    },},},

       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(2650,160),    order     = 50,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "talk",
             params = {"hqg",TR("你就替我守着好了，就算天塌下来也不要吵醒我！"),"1142.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"yg",TR("哦！好的！老前辈！"),"1143.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"yg","hqg"},},
    },
       {remove = { model = {"text-board", }, },},


    {
        delay = {time = 0.2,},
    },

       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(2580,210),    order     = 40,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0, rotation3D=cc.vec3(15,210,78),
        },},

    {
        delay = {time = 0.4,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},

      {
          load = {tmpl = "zm",
              params = {TR("数个时辰之后……"),"750"},},
      },


     {delay = {time = 0.6,},},

    {remove = { model = {"750", }, },},







       {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2500,160),    order     = 50,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "yguo",sync = true,what = {move = {
                   time = 0.2,by = cc.p(-200,100),},},},},


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2300,260),    order     = 50,
            file = "hero_yangguo_hei",    animation = "win",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


     {
         music = {file = "battle1.mp3",},
     },





    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(3200,250),    order     = 70,
            file = "hero_luzhangke",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(3200,200),    order     = 70,
            file = "hero_nimoxing",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "lzsren",     type  = DEF.FIGURE,
            pos= cc.p(3200,100),    order     = 70,
            file = "hero_lingzhishangren",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "lzke",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2860,200),
                                 control={cc.p(3200,250),cc.p(2800,600),}
    },},},
    },},},

    {action = {tag  = "nmxing",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2800,160),
                                 control={cc.p(3200,200),cc.p(2800,500),}
    },},},
    },},},

    {action = {tag  = "lzsren",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2600,160),
                                 control={cc.p(3200,100),cc.p(2800,400),}
    },},},
    },},},

       {remove = { model = {"lzsren", }, },},

    {   model = {
            tag  = "lzsren",     type  = DEF.FIGURE,
            pos= cc.p(2600,160),    order     = 72,
            file = "hero_lingzhishangren",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"lzk","lzk.png",TR("藏边五丑")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzk",TR("咦！？这不是那个老乞丐吗？竟然断气了？"),"1144.mp3"},},
     },


     {
         load = {tmpl = "move1",
             params = {"lzsr","lzsr.png",TR("藏边五丑")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzsr",TR("这老乞丐追了我们这么久，没想到却死在了这里，真是老天都帮着我们！"),"1145.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lzk",TR("不能让这老东西死得这么舒坦，我们应该把他大卸八块扔到山下喂狼！"),"1146.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"lzsr","lzk"},},
    },

       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2300,260),    order     = 50,
            file = "hero_yangguo_hei",    animation = "pose",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "yguo",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2680,210),
                                 control={cc.p(2300,260),cc.p(2440,600),}
    },},},
    },},},


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2680,210),    order     = 50,
            file = "hero_yangguo_hei",    animation = "shoushang",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},
       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(2580,210),    order     = 55,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0, rotation3D=cc.vec3(15,210,78),
        },},








     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","0.8","-2500","-200"},},
     },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(3500,200),
                                 control={cc.p(2600,210),cc.p(3000,600),}
    },},},
    },},},
    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(3400,200),
                                 control={cc.p(2600,210),cc.p(3000,600),}
    },},},
    },},},

    {
        delay = {time = 0.2,},
    },

       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(3500,200),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},



       {remove = { model = {"lzke", }, },},
       {remove = { model = {"nmxing", }, },},
    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(2860,200),    order     = 70,
            file = "hero_luzhangke",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(2800,160),    order     = 71,
            file = "hero_nimoxing",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"lzk","lzk.png",TR("藏边五丑")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzk",TR("臭小子，你是什么人，敢和我们藏边五丑作对，我看你是活得不耐烦了吧！"),"1147.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"lzk"},},
    },

       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(3500,200),    order     = 50,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.4","0.8","-2400","-140"},},
     },



        {action = { tag  = "yguo",sync = true,what = {move = {
                   time = 0.6,by = cc.p(-200,0),},},},},




       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(3300,200),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "move2",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("我答应过老前辈，守护他三天三夜，我杨过说到做到，无论他是死是活，我都不会让你们碰他的！"),"1148.mp3"},},
     },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "lzsren",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2900,60),
                                 control={cc.p(2600,160),cc.p(2800,400),}
    },},},
    },},},



     {
         load = {tmpl = "move1",
             params = {"lzsr","lzsr.png",TR("藏边五丑")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzsr",TR("那你就陪这老乞丐一起去死吧！"),"1149.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"lzsr","yg"},},
    },

       {remove = { model = {"text-board", }, },},




       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3500,160),    order     = 75,
            file = "hero_hongqigong",    animation = "pugong",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "hero_hongqigong_pugong.mp3",sync=false,},
    },

    {
        delay = {time = 0.5,},
    },
     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.2","0.7","-2100","-100"},},
     },
    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(3050,180),
                                 control={cc.p(3500,160),cc.p(3200,400),}
    },},},
    },},},




       {remove = { model = {"lzke", }, },},
       {remove = { model = {"nmxing", }, },},
    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(2860,200),    order     = 70,
            file = "hero_luzhangke",    animation = "aida",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(2800,160),    order     = 71,
            file = "hero_nimoxing",    animation = "aida",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},
       {remove = { model = {"lzsren", }, },},

    {   model = {
            tag  = "lzsren",     type  = DEF.FIGURE,
            pos= cc.p(2900,60),    order     = 72,
            file = "hero_lingzhishangren",    animation = "aida",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},



        {action = { tag  = "lzke",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-200,40),},},},},
        {action = { tag  = "nmxing",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-200,0),},},},},
        {action = { tag  = "lzsren",sync = true,what = {move = {
                   time = 0.4,by = cc.p(-200,-40),},},},},


       {remove = { model = {"lzke", }, },},
       {remove = { model = {"nmxing", }, },},
    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(2660,200),    order     = 70,
            file = "hero_luzhangke",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(2600,160),    order     = 71,
            file = "hero_nimoxing",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,0,0),
        },},
       {remove = { model = {"lzsren", }, },},

    {   model = {
            tag  = "lzsren",     type  = DEF.FIGURE,
            pos= cc.p(2700,60),    order     = 72,
            file = "hero_lingzhishangren",    animation = "yun",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,0,0),
        },},
       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3050,180),    order     = 75,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"lzk","lzk.png",TR("藏边五丑")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzk",TR("哼！老乞丐你别得意，我们师祖金轮法王，武功天下第一！一定会为我们报仇的！"),"1150.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"lzk"},},
    },


     {
         load = {tmpl = "move1",
             params = {"oyf","oyf.png",TR("欧阳锋")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyf",TR("谁？谁敢和我争天下第一！"),"1151.mp3"},},
     },




	{
        music = {file = "jq_yt.mp3",},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.7","-1600","-100"},},
     },

    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2000,-50),    order     = 75,
            file = "hero_ouyangfeng",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "oyfeng",sync = false,what = {move = {
                   time = 2.0,by = cc.p(600,0),},},},},
    -- {action = {tag  = "oyfeng",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    -- {bezier = {time = 0.5,to = cc.p(2500,180),
    --                              control={cc.p(2000,160),cc.p(2300,400),}
    -- },},},
    -- },},},


       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3050,100),    order     = 75,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},



    {
        delay = {time = 1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","0.7","-1950","-100"},},
     },
    {
        delay = {time = 1,},
    },

       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2600,-50),    order     = 75,
            file = "hero_ouyangfeng",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.2,},
    },
       {remove = { model = {"lzke", }, },},
       {remove = { model = {"nmxing", }, },},
    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(2660,200),    order     = 70,
            file = "hero_luzhangke",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(2600,160),    order     = 71,
            file = "hero_nimoxing",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,180,0),
        },},
       {remove = { model = {"lzsren", }, },},

    {   model = {
            tag  = "lzsren",     type  = DEF.FIGURE,
            pos= cc.p(2700,60),    order     = 72,
            file = "hero_lingzhishangren",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
        {action = { tag  = "lzke",sync = false,what = {move = {
                   time = 0.2,by = cc.p(-500,600),},},},},
        {action = { tag  = "nmxing",sync = false,what = {move = {
                   time = 0.2,by = cc.p(-500,600),},},},},
        {action = { tag  = "lzsren",sync = true,what = {move = {
                   time = 0.2,by = cc.p(-500,600),},},},},

       {remove = { model = {"lzke", }, },},
       {remove = { model = {"nmxing", }, },},
       {remove = { model = {"lzsren", }, },},



     {
         load = {tmpl = "talk",
             params = {"oyf",TR("是你！？你的武功很厉害，你是谁？"),"1152.mp3"},},
     },


     {
         load = {tmpl = "move2",
             params = {"hqg","hqg.png",TR("洪七公")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hqg",TR("我？嘿嘿嘿！我是欧阳锋！你又是什么人？"),"1153.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyf",TR("我！？我怎么知道我是谁？你知道吗？"),"1154.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"hqg",TR("哦~！你不就是臭蛤蟆！你居然连自己是谁都忘了！哈哈哈！"),"1155.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyf",TR("欧阳锋，你笑什么？有什么好笑的？"),"1156.mp3"},},
     },




    {
        load = {tmpl = "out3",
            params = {"oyf","hqg"},},
    },

       {remove = { model = {"text-board", }, },},









       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2600,0),    order     = 75,
            file = "hero_ouyangfeng",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3050,50),    order     = 75,
            file = "hero_hongqigong",    animation = "nuji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "hero_hongqigong_pugong.mp3",sync=false,},
    },
    {
        sound = {file = "hero_ouyangfeng_pugong.mp3",sync=false,},
    },



    {
        delay = {time = 1.5,},
    },
        {action = { tag  = "oyfeng",sync = false,what = {move = {
                   time = 0.2,by = cc.p(50,0),},},},},
        {action = { tag  = "hqgong",sync = false,what = {move = {
                   time = 0.2,by = cc.p(-50,0),},},},},
    {   model = {
            tag  = "long",     type  = DEF.FIGURE,
            pos= cc.p(800,0),    order     = 30,
            file = "effect_hongqigong_nuji",    animation = "animation",
            scale = 2.5,   parent = "hqgong", opacity=255,
            loop = true,   endRlease = true,  speed=0.75, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.8,},
    },


        {action = { tag  = "oyfeng",sync = false,what = {move = {
                   time = 0.3,by = cc.p(-200,0),},},},},
        {action = { tag  = "hqgong",sync = true,what = {move = {
                   time = 0.3,by = cc.p(200,0),},},},},


       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2450,0),    order     = 75,
            file = "hero_ouyangfeng",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.0, rotation3D=cc.vec3(0,0,0),
        },},

       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3200,50),    order     = 75,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.0, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "yguo",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2800,200),
                                 control={cc.p(3300,200),cc.p(3000,600),}
    },},},
    },},},

    {
        delay = {time = 0.2,},
    },

       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2800,200),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    -- {
    --     delay = {time = 0.8,},
    -- },



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("爹！老前辈！你们别打了！"),"1157.mp3"},},
     },



    {
        load = {tmpl = "out1",
            params = {"yg"},},
    },

       {remove = { model = {"text-board", }, },},









       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2450,0),    order     = 75,
            file = "hero_ouyangfeng",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "oyfeng",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2600,200),
                                 control={cc.p(2500,300),cc.p(2600,200),}
    },},},
    },},},

    {
        delay = {time = 0.1,},
    },


       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(3200,50),    order     = 75,
            file = "hero_hongqigong",    animation = "pugong",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.14,},},
    {bezier = {time = 0.4,to = cc.p(2900,200),
                                 control={cc.p(3100,300),cc.p(2900,200),}
    },},},
    },},},


    {
        sound = {file = "hero_hongqigong_pugong.mp3",sync=false,},
    },
    {
        sound = {file = "hero_ouyangfeng_pugong.mp3",sync=false,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyfeng",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.1,},},
    {bezier = {time = 1.2,to = cc.p(2000,360),
                                 control={cc.p(2600,200),cc.p(2300,100),}
    },},},
    },},},

    {action = {tag  = "hqgong",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.1,},},
    {bezier = {time = 1.2,to = cc.p(2200,360),
                                 control={cc.p(2900,200),cc.p(2600,100),}
    },},},
    },},},

    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.9","0.6","-1200","-150"},},
     },
    {
        delay = {time = 0.9,},
    },
    {
        model = {tag = "oyfeng",speed =6,},
    },
    {
        model = {tag = "hqgong",speed =6,},
    },
    {
        delay = {time = 0.2,},
    },
    {
        model = {tag = "oyfeng",speed =1.5,},
    },
    {
        model = {tag = "hqgong",speed =1.5,},
    },

    {
        sound = {file = "hero_hongqigong_pugong.mp3",sync=false,},
    },
    {
        sound = {file = "hero_ouyangfeng_pugong.mp3",sync=false,},
    },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {action = {tag  = "oyfeng",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.06,},},
    {bezier = {time = 1.2,to = cc.p(1460,580),
                                 control={cc.p(2000,400),cc.p(1750,480),}
    },},},
    },},},

    {action = {tag  = "hqgong",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.06,},},
    {bezier = {time = 1.2,to = cc.p(1560,580),
                                 control={cc.p(2200,400),cc.p(1900,480),}
    },},},
    },},},

    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.9","0.6","-900","-150"},},
     },
    {
        delay = {time = 0.9,},
    },

    {
        model = {tag = "oyfeng",speed =4,},
    },
    {
        model = {tag = "hqgong",speed =4,},
    },
    {
        delay = {time = 0.6,},
    },

    {
        sound = {file = "hero_hongqigong_pugong.mp3",sync=false,},
    },
    {
        sound = {file = "hero_ouyangfeng_pugong.mp3",sync=false,},
    },

    {
        model = {tag = "oyfeng",speed = 1.5,},
    },
    {
        model = {tag = "hqgong",speed = 1.5,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "oyfeng",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.02,},},
    {bezier = {time = 1.2,to = cc.p(1960,560),
                                 control={cc.p(1460,580),cc.p(1710,610),}
    },},},
    },},},

    {action = {tag  = "hqgong",sync = true,what ={ spawn={{scale= {time = 1.2,to = 0.02,},},
    {bezier = {time = 1.2,to = cc.p(2000,560),
                                 control={cc.p(1560,580),cc.p(1790,610),}
    },},},
    },},},

    {
        delay = {time = 0.2,},
    },


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2400,100),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.9","0.7","-1600","-150"},},
     },
    {
        delay = {time = 1.2,},
    },




    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(3000,100),    order     = 60,
            file = "hero_yinggu",    animation = "nuji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "hero_yinggu_nuji.mp3",sync=false,},
    },


     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.8","0.7","-1600","-200"},},
     -- },
    {
        delay = {time = 0.8,},
    },
    {
        model = {tag = "yinggu",speed = 1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "yinggu",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.14,},},
    {bezier = {time = 1.2,to = cc.p(2650,100),
                                 control={cc.p(3000,100),cc.p(2850,400),}
    },},},
    },},},

    {
        delay = {time = 1.2,},
    },

       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2400,100),    order     = 50,
            file = "hero_yangguo_hei",    animation = "aida",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.5,},
    },


       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2400,100),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.1,},
    },
       {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(2400,100),    order     = 50,
            file = "hero_yangguo_hei",    animation = "shoushang",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
        delay = {time = 0.3,},
    },

       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(2650,100),    order     = 50,
            file = "hero_yinggu",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.9","0.7","-1850","-100"},},
     },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("你是谁？你想做什么？"),"1158.mp3"},},
     },


     {
         load = {tmpl = "move2",
             params = {"ygu","ygu.png",TR("神秘老妪")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ygu",TR("你一路上都在打听一个美丽的白衣女子，她——是你什么人？"),"1159.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("（这个人神色不善，恐怕会对姑姑不利！得想个办法把她骗过去……）"),"1160.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"ygu",TR("哼哼哼！——是你师父对不对？"),"1161.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("啊！？"),"1162.mp3"},},
     },












       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(2650,100),    order     = 50,
            file = "hero_yinggu",    animation = "win",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "talk1",
             params = {"ygu",TR("哈哈哈！你终于出现了，没想到过了这么久，你还是如此的美丽年轻！"),"1163.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"ygu",TR("不过——很快……很快这一切都将是我的！哈哈哈——"),"1164.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"yg","ygu"},},
    },


    {
        delay = {time = 0.5,},
    },

       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(2650,100),    order     = 50,
            file = "hero_yinggu",    animation = "nuji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 1.2,},
    },

    {
        model = {tag = "yinggu",speed = 0.2,},
    },

    {
        delay = {time = 0.5,},
    },

     {
         load = {tmpl = "move1",
             params = {"hqg","hqg.png",TR("洪七公")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hqg",TR("住手！"),"1165.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"hqg"},},
    },

     {
         load = {tmpl = "move1",
             params = {"oyf","oyf.png",TR("欧阳锋")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyf",TR("放开我的乖儿子！"),"1166.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"oyf"},},
    },




       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(2000,250),    order     = 75,
            file = "hero_hongqigong",    animation = "nuji",
            scale = 0.1,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "hero_hongqigong_nujidongzuo.mp3",sync=false,},
    },


    {
        delay = {time = 0.5,},
    },


    {
        model = {tag = "yinggu",speed = 1,},
    },
    {
        model = {tag = "hqgong",speed = 1.5,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "hqgong",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2600,100),
                                 control={cc.p(2000,250),cc.p(2300,175),}
    },},},
    },},},

    {   model = {
            tag  = "long1",     type  = DEF.FIGURE,
            pos= cc.p(800,0),    order     = 30,
            file = "effect_hongqigong_nuji",    animation = "animation",
            scale = 2.5,   parent = "hqgong", opacity=255,
            loop = true,   endRlease = true,  speed=0.75, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "hero_hongqigong_nuji.mp3",sync=false,},
    },

    {
        delay = {time = 1.2,},
    },


       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(2650,100),    order     = 50,
            file = "hero_yinggu",    animation = "aida",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.3","0.7","-2000","-100"},},
     },



        {action = { tag  = "yinggu",sync = true,what = {move = {
                   time = 0.3,by = cc.p(300,0),},},},},








       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2000,300),    order     = 75,
            file = "hero_ouyangfeng",    animation = "nuji",
            scale = 0.1,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "hero_ouyangfeng_nuji1.mp3",sync=false,},
    },


    {
        delay = {time = 1,},
    },


       {remove = { model = {"hqgong", }, },},
    {   model = {
            tag  = "hqgong",     type  = DEF.FIGURE,
            pos= cc.p(2600,100),    order     = 75,
            file = "hero_hongqigong",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},




    {
        model = {tag = "oyfeng",speed = 1.5,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyfeng",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(2800,100),
                                 control={cc.p(2000,250),cc.p(2400,200),}
    },},},
    },},},

    {
        delay = {time = 1,},
    },


    --    {remove = { model = {"yinggu", }, },},
    -- {   model = {
    --         tag  = "yinggu",     type  = DEF.FIGURE,
    --         pos= cc.p(2650,100),    order     = 50,
    --         file = "hero_yinggu",    animation = "aida",
    --         scale = 0.14,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
    --     },},

        {action = { tag  = "yinggu",sync = true,what = {move = {
                   time = 0.4,by = cc.p(250,0),},},},},

    {
        delay = {time = 0.7,},
    },


       {remove = { model = {"oyfeng", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(2800,100),    order     = 75,
            file = "hero_ouyangfeng",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(3200,100),    order     = 50,
            file = "hero_yinggu",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.1,},
    },

     {
         load = {tmpl = "move2",
             params = {"ygu","ygu.png",TR("神秘老妪")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ygu",TR("——哈哈哈哈哈——啊哈哈哈哈哈！"),"1167.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"ygu"},},
    },

       {remove = { model = {"yinggu", }, },},
    {   model = {
            tag  = "yinggu",     type  = DEF.FIGURE,
            pos= cc.p(3200,100),    order     = 50,
            file = "hero_yinggu",    animation = "daiji",
            scale = 0.14,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "yinggu",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.14,},},
    {bezier = {time = 0.2,to = cc.p(3600,100),
                                 control={cc.p(3200,100),cc.p(3300,500),}
    },},},
    },},},










    {
       delay = {time = 0.1,},
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
