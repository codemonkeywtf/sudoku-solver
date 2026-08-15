package fonts 

import rl "vendor:raylib"

Fonts :: struct {
    bold:    rl.Font,   // locked
    light:   rl.Font,   // pencil marks
    regular: rl.Font,   // unlocked
}

init :: proc() -> Fonts {
    fonts := Fonts {
        light   = rl.LoadFont("assets/fonts/static/RobotoMono-ExtraLight.ttf"),
        regular = rl.LoadFont("assets/fonts/static/RobotoMono-Light.ttf"),
        bold    = rl.LoadFont("assets/fonts/static/RobotoMono-SemiBold.ttf"),
    }
    rl.SetTextureFilter(fonts.bold.texture, .BILINEAR)
    rl.SetTextureFilter(fonts.light.texture, .BILINEAR)
    rl.SetTextureFilter(fonts.regular.texture, .BILINEAR)
    return fonts
}

destroy :: proc(fonts: ^Fonts) {
    rl.UnloadFont(fonts.bold)
    rl.UnloadFont(fonts.light)
    rl.UnloadFont(fonts.regular)
}
