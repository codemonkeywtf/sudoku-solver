package main

import rl "vendor:raylib"

//----------------------------------------------------------
// Theme 
//----------------------------------------------------------
Theme :: struct {
    bg:             rl.Color,
    line_thin:      rl.Color,
    line_thick:     rl.Color,
    highlight:      rl.Color,
    highlight_r_c:  rl.Color,
    font_color:     rl.Color,
    error_color:    rl.Color,
    locked_bg:      rl.Color,
    locked_outline: rl.Color,
}

light_theme := Theme {
    bg              = rl.RAYWHITE,
    line_thin       = rl.LIGHTGRAY,
    line_thick      = rl.BLACK,
    highlight       = {100, 180, 255, 100}, // soft blue, semi-transparent
    highlight_r_c   = {100, 180, 255, 50},  // very soft row,col
    font_color      = rl.BLACK,
    error_color     = rl.RED,
    locked_bg       = {220, 230, 250, 80},  // soft blue-ish tint
    locked_outline  = {190, 170, 230, 200}   // very soft lavender
}

dark_theme := Theme {
    bg              = {30, 30, 30, 255},    // near-black
    line_thin       = {80, 80, 80, 255},    // medium gray 
    line_thick      = {200, 200, 200, 255}, // light gray / almost white 
    highlight       = {80, 140, 220, 120},  // a bit stronger blue for dark mode
    highlight_r_c  = {80, 140, 220, 50},    // very soft row,col
    font_color      = rl.RAYWHITE,
    error_color     = rl.RED,
    locked_bg       = {50, 70, 110, 90},    // slightly lighter/cooler dark blue
    locked_outline  = {70, 170, 160, 100}  // soft teal
}
