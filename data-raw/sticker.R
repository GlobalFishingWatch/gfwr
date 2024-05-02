#install.packages("svglite")
#install.packages("hexSticker")
library(hexSticker)

imgurl <- "data-raw/GFW_STACKED H RGB.png"

sticker(imgurl,
        package = "",
        h_fill = "white", #background
        p_color = "#1b4b87", #packagename color
        p_family = "mono",
        p_fontface = "bold",
        p_y = 0.4,
        p_x = 1,
        p_size = 16,
        s_x = 1,
        s_y = 1,
        s_width = 0.8,
        # h_color = "#f05032",
        h_color = "#8abbc7", #this!
        h_size =  1.3,
        white_around_sticker = FALSE,
        spotlight = FALSE,
        #url = "a",
        #u_x = 1,
        #u_y = 0.08,
        #u_color = "black",
        #u_family = "Aller_Rg",
        #u_size = 1.5,
        #u_angle = 30,
        filename = "man/figures/gfwr_hex_rgb.png")
