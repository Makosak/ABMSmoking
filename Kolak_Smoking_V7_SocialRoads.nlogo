
globals [
         ;; # of decays during this tick
number-retail
]             


breed [ retail ]
patches-own [countdown ]
turtles-own [
 satiation?  ;;   satiation? score 
 pSmoke     ;;   Individual Smoking parameter
 rD         ;;   Baseline smoking rate
 smoke      ;;   Craving parameter
 hD         ;;   Rate of decay
 maxdecay
 decays

]

;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  
  ;make-zone
  color-patches
  
  create-turtles number-people [           ;; original has 5,000 persons
    set size 5
    set shape "person"
    set xcor random 500 
    set ycor random 500
    face one-of neighbors4 
    ;pen-down
    
    set satiation? 0  ;; whether or not smoker is smoking; if 1 then smoking
    ;set pSmoke 0.40  ;;   Individual Smoking parameter
    ;set rD 0.25  ;;   Baseline smoking rate
    set decays random 10
    set maxdecay 10
    
    
    
    ;set pA 0.25  ;; probability that agent is an abstainer
    let N random-float 1.0  ;; N is a random number
    ifelse N <= pA 
    [ set rD 0.0 set color white]  
        ;; if abstainer, baseline smoking rate is 0.
    [ set  rD random-gamma 2 0.25 set color red pen-down] 
        ;; is smoker, generate baseline smoking rate from Gamma distribution

  ]
  
  reset-ticks
end

to make-retail [ number ]
  create-retail number-retail [
    set size 1
    set color red
    set shape "square"
    setxy random-xcor random-ycor
  ]
end

 

;;;;;;;;;;;;;;;;;;;;;;
;; Go Procedures    ;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  if ticks > 1440 [stop]
   
  ask turtles with [rD > 0.0]
   
     [set decays decays + 1
      
      support 
      
      peer-pressure 
      
      advertiseSmoke
      
      noSmokeZone
      
      if satiation? = 0              ;; if craving, make a decision
      [  decide  ]
        
      if decays > maxdecay          ;; after 10 minutes, start craving
        [ set satiation? 0
          set rD random-gamma 2 0.25   
          set color red
          set decays 0] ] 
    
    ask turtles [ walk2 ]
    
  tick
 

end


;;;;;;;;;;;;;;;;;;;;;;
;; Turtle Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

to peer-pressure  ;; turtle procedure
   let nearby-smokers (turtles-on neighbors)
     with [ rd > 0.0 ]

     if nearby-smokers != nobody
     [ set rD rD + (rD * peerP) ]   ;; increase probability of smoking
end

to support  ;; turtle procedure
     let nearby-abstainers (turtles-on neighbors)
     with [ rd = 0.0 ]
     
     if nearby-abstainers != nobody 
     [ set rD rD - (rD * (random-float 1.0 ))]  ;; decrease probability of smoking
end


to advertiseSmoke ;; turtle procedure
  let P patches in-radius 3
  if [pcolor] of P = red
  [ set rD rD + (rD * adP) ]
end

to noSmokeZone ;; turtle procedure
  let P patches in-radius 3
  if [pcolor] of P = green
  [ set rD rD - (rD * healthP) ]
end


to decide
      if random-gamma 2 0.25 < rD  ;; if agent smokes, turns yellow, start decay
          [ 
          set satiation? 1
          set color yellow
          set decays decays + 1 
          set rD random-gamma 2 0.25]   ;; reset smoking parameter
end


;;;;;;;;;;;;;;;;;;;;;;
;; Walk Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;
          

to walk1
    face one-of neighbors4              ;; face N, E, S, or W
    forward 1                           ;; advance one step
end

to walk2
    rt one-of [-90 0 90]                ;; go left, straight, or right
    forward 1                           ;; advance one step
end

to wander 
  rt random-float 360
  fd 1
end

to walk110
    face one-of neighbors4              ;; face N, E, S, or W
    forward 10                           ;; advance one step
end

to walk210
    rt one-of [-90 0 90]                ;; go left, straight, or right
    forward 10                           ;; advance one step
end

to wander10
  rt random-float 360
  fd 10
end


;;;;;;;;;;;;;;;;;;;;;;
;; Patch Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

to make-zone  

  let ycounter random-ycor
  let zone-color red 
  
  
  while [ ycounter < max-pycor - 60 ] [
    
    ; do the west side
    set zone-color one-of [ red green ]
    ask patches with [ pxcor > 50 and pxcor < 60 and pycor > ycounter and pycor < ycounter + 10 ] 
    [
      ; In this part we can decide what color we would like to make each set of patches
      ; (i.e. each individual zone). Randomly assign to a zone type, e.g. tobacco retail or health zone
      set pcolor zone-color
    ] ; ask
    
    ; do the same thing for the east side
    set zone-color one-of [ red green ]
    ask patches with [ pxcor > max-pxcor - 100 and pxcor < max-pxcor - 50 and pycor > ycounter and pycor < ycounter + 50] [
      set pcolor zone-color
    ]; ask
    
    
    set ycounter ( ycounter + 100 )
  ] ; while  
  
  end


to color-patches 
  let total SmokeZone + HealthZone + 0.90
  let p-red   SmokeZone / (total)
  let p-green HealthZone / (total)


  ask patches [
    let x random-float 1.0
    if x <= p-red + p-green + 0.90 [set pcolor black]
    if x <= p-red + p-green [set pcolor green]
    if x <= p-red [set pcolor red]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;
;; Report Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

to-report smkPerc 
  report (count turtles with [ satiation? = 1] / ( (count turtles with [ satiation? = 1])+ (count turtles with [ color = red]))) * 100
end
@#$#@#$#@
GRAPHICS-WINDOW
205
10
1991
1817
-1
-1
3.545
1
10
1
1
1
0
1
1
1
0
500
0
500
0
0
1
ticks
30.0

BUTTON
13
30
104
63
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
145
186
178
pA
pA
0
1.0
0.8
.05
1
NIL
HORIZONTAL

SLIDER
12
227
184
260
peerP
peerP
0
1.0
0.5
0.1
1
NIL
HORIZONTAL

TEXTBOX
14
112
219
154
pA: probability that individual abstains from smoking.
11
0.0
1

TEXTBOX
13
196
186
238
peerP: rate parameter affecting influence of nearby smokers
11
0.0
1

BUTTON
106
30
184
63
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
68
184
101
number-people
number-people
0
2000
1500
100
1
NIL
HORIZONTAL

PLOT
817
385
1128
621
World % Smoking Now 
time
percent
0.0
5.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [ satiation? ] of turtles / number-people) * 100"

PLOT
815
14
1091
183
Mean Probability of Smoking
NIL
NIL
0.01
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [ rD ] of turtles"

MONITOR
818
193
1089
238
% Smokers Smoking
(count turtles with [ satiation? = 1] / ( (count turtles with [ satiation? = 1])+ (count turtles with [ color = red]))) * 100
2
1
11

MONITOR
816
252
1003
297
Mean Probability of Smoking
(( mean [rD] of turtles )) * 100
2
1
11

MONITOR
818
325
875
370
hours
ticks / 60
2
1
11

MONITOR
943
327
1090
372
World % Smoking Now
(sum [ satiation? ] of turtles / number-people) * 100
2
1
11

SLIDER
11
285
183
318
adP
adP
0
1.0
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
11
346
183
379
healthP
healthP
0
1.0
0.6
0.1
1
NIL
HORIZONTAL

MONITOR
11
394
99
439
Smoke Zone
count turtles with [pcolor = red]
17
1
11

SLIDER
11
454
190
487
SmokeZone
SmokeZone
0
0.10
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
12
498
189
531
HealthZone
HealthZone
0
0.1
0.01
0.01
1
NIL
HORIZONTAL

MONITOR
105
394
192
439
Health Zone
count turtles with [pcolor = green]
17
1
11

TEXTBOX
13
268
194
296
adP: influence of tobacco retail\n
11
0.0
1

TEXTBOX
12
328
193
356
healthP: influence of health zone
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Influence-Ad" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count turtles</metric>
    <metric>smkPerc</metric>
    <metric>mean [rD] of turtles</metric>
    <enumeratedValueSet variable="number-people">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pA">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peerP">
      <value value="0.1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="adP" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="healthP">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HealthZone">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SmokeZone">
      <value value="0.05"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SmokeZone" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count turtles</metric>
    <metric>smkPerc</metric>
    <metric>mean [rD] of turtles</metric>
    <enumeratedValueSet variable="pA">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-people">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adP">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="healthP">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peerP">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="HealthZone" first="0" step="0.01" last="0.1"/>
    <enumeratedValueSet variable="SmokeZone">
      <value value="0.01"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="HealthZone" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count turtles</metric>
    <metric>smkPerc</metric>
    <metric>mean [rD] of turtles</metric>
    <enumeratedValueSet variable="pA">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-people">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adP">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="healthP">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peerP">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HealthZone">
      <value value="0.01"/>
    </enumeratedValueSet>
    <steppedValueSet variable="SmokeZone" first="0" step="0.01" last="0.1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
