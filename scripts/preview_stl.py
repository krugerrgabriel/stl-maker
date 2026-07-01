#!/usr/bin/env python3
"""Gera previews PNG (6 vistas) de um STL, 100% headless (matplotlib).

Uso: preview_stl.py <arquivo.stl> <pasta-de-saida>
"""
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import trimesh
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

VISTAS = {
    "iso": (30, -60),
    "frente": (0, -90),
    "tras": (0, 90),
    "direita": (0, 0),
    "esquerda": (0, 180),
    "topo": (90, -90),
}
MAX_FACES = 30000  # acima disso, simplifica para o matplotlib não travar


def main(stl: str, out_dir: str) -> None:
    os.makedirs(out_dir, exist_ok=True)
    mesh = trimesh.load(stl, force="mesh")
    if len(mesh.faces) > MAX_FACES:
        try:
            mesh = mesh.simplify_quadric_decimation(face_count=MAX_FACES)
        except BaseException:
            pass  # preview com malha cheia, só fica mais lento

    # sombreamento simples por normal de face para dar leitura de volume
    luz = np.array([0.5, -0.5, 0.8])
    luz /= np.linalg.norm(luz)
    brilho = np.clip(mesh.face_normals @ luz, 0, 1) * 0.65 + 0.30
    cores = np.stack([brilho * 0.45, brilho * 0.65, brilho * 0.95], axis=1)

    centro = mesh.bounds.mean(axis=0)
    dim = mesh.bounds[1] - mesh.bounds[0]
    raio = dim.max() / 2 * 1.15

    for nome, (elev, azim) in VISTAS.items():
        fig = plt.figure(figsize=(6, 6), dpi=110)
        ax = fig.add_subplot(projection="3d")
        ax.add_collection3d(
            Poly3DCollection(mesh.triangles, facecolors=np.clip(cores, 0, 1))
        )
        for i, eixo in enumerate("xyz"):
            getattr(ax, f"set_{eixo}lim")(centro[i] - raio, centro[i] + raio)
        ax.view_init(elev=elev, azim=azim)
        ax.set_box_aspect((1, 1, 1))
        ax.set_xlabel("X")
        ax.set_ylabel("Y")
        ax.set_zlabel("Z")
        ax.set_title(f"{nome} — {dim[0]:.1f} x {dim[1]:.1f} x {dim[2]:.1f} mm")
        fig.savefig(os.path.join(out_dir, f"{nome}.png"), bbox_inches="tight")
        plt.close(fig)

    print(f"6 previews gerados em {out_dir}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
