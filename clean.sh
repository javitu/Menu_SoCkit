#!/usr/bin/env bash

# Trabaja desde el directorio donde está el script (la raíz del proyecto),
# para poder ejecutarlo con seguridad desde cualquier sitio.
cd "$(dirname "$0")" || exit 1

rm -rf db \
       incremental_db \
       output_files \
       simulation \
       greybox_tmp \
       hc_output \
       .qsys_edit \
       hps_isw_handoff \
       sys/.qsys_edit \
       sys/vip

rm -rf sys/*_sim ./*_sim

find . -type f \( \
    -name '*.bak'           -o \
    -name '*.orig'          -o \
    -name '*.rej'           -o \
    -name '*~'              -o \
    -name '*.qws'           -o \
    -name '*.ppf'           -o \
    -name '*.ddb'           -o \
    -name '*.csv'           -o \
    -name '*.cmp'           -o \
    -name '*.sip'           -o \
    -name '*.spd'           -o \
    -name '*.bsf'           -o \
    -name '*.f'             -o \
    -name '*.sopcinfo'      -o \
    -name '*.xml'           -o \
    -name 'new_rtl_netlist' -o \
    -name 'old_rtl_netlist' \
\) -delete

rm -f build_id.v \
      c5_pin_model_dump.txt \
      PLLJ_PLLSPE_INFO.txt \
      ./*.cdf \
      ./*.rpt
