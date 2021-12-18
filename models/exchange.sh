#!/bin/bash

# input_C=(
# "waist"
# "chest"
# )
# output_C=(
# "BASE_LINK"
# "CHEST_LINK0"
# )

input_L=(
"index_link0"
"index_link1"
"middle_link0"
"palm_link0"
"thumb_link0"
"thumb_link1"
)
output_wo_LR=(
"INDEX_LINK0"
"INDEX_LINK1"
"MIDDLE_LINK0"
"PALM_LINK0"
"THUMB_LINK0"
"THUMB_LINK1"
)

function edit_colors() {
  awk -i inplace '{
    if ( $1 == "specularColor" ) {
      $2 = 0.1
      $3 = 0.1
      $4 = 0.1
      print "          " $1 "    " $2 " " $3 " " $4
    } else if ( $1 == "shininess" ) {
      $2 = 0.5
      print "          " $1 "        " $2
    } else if ( $1 == "ambientIntensity" ) {
      $2 = 0.2
      print "          " $1 " " $2
    } else {
      print $0
    }
  }' $1
}

if [ ! -e ./byproduct ];then
    mkdir ./byproduct/
fi
if [ ! -e ./exchanged_wrl ];then
    mkdir ./exchanged_wrl/
fi

#compress and mirror models
for i in "${!input_L[@]}"
do
  meshlabserver -i ./original_wrl/${input_L[$i]}.wrl -o ./byproduct/R_${output_wo_LR[$i]}.obj  -s ./original_wrl/mesh_reduction.mlx -om fc
  meshlabserver -i ./byproduct/R_${output_wo_LR[$i]}.obj      -o ./byproduct/L_${output_wo_LR[$i]}.obj  -s ./flip_Y.mlx         -om fc
  roseus "(load \"package://eus_assimp/euslisp/eus-assimp.l\")" \
         "(setq glv (load-mesh-file \"byproduct/R_${output_wo_LR[$i]}.obj\" :scale 1.0))" \
         "(save-mesh-file \"R_${output_wo_LR[$i]}.wrl\" glv :scale 1.0)"\
         "(setq glv (load-mesh-file \"byproduct/L_${output_wo_LR[$i]}.obj\" :scale 1.0))" \
         "(save-mesh-file \"L_${output_wo_LR[$i]}.wrl\" glv :scale 1.0)"\
         "(exit)"
  edit_colors L_${output_wo_LR[$i]}.wrl
  edit_colors R_${output_wo_LR[$i]}.wrl
  mv L_${output_wo_LR[$i]}.wrl ./exchanged_wrl/
  mv R_${output_wo_LR[$i]}.wrl ./exchanged_wrl/
done
