#!/usr/bin/env python3
"""Valida um STL para impressão 3D: estanqueidade, dimensões e volume.

Uso: validar_stl.py <arquivo.stl>
Sai com código 1 se o STL não estiver estanque (e o reparo automático falhar).
"""
import sys

import trimesh


def main(path: str) -> int:
    m = trimesh.load(path, force="mesh")
    d = m.bounds[1] - m.bounds[0]
    print(f"Arquivo........: {path}")
    print(f"Triângulos.....: {len(m.faces)}")
    print(f"Dimensões (mm).: {d[0]:.2f} x {d[1]:.2f} x {d[2]:.2f}")

    if m.is_watertight:
        print(f"Volume.........: {m.volume / 1000:.2f} cm³")
        print("Estanque.......: SIM — pronto para o slicer")
        return 0

    print("Estanque.......: NÃO — tentando reparo automático...")
    trimesh.repair.fix_normals(m)
    trimesh.repair.fill_holes(m)
    if m.is_watertight:
        reparado = path[:-4] + "_reparado.stl"
        m.export(reparado)
        print(f"Reparo OK → {reparado} (use este no slicer)")
        return 0

    print("Reparo automático falhou: revise o modelo antes de imprimir.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
