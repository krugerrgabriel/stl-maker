#!/usr/bin/env python3
"""Gera previews PNG (6 vistas) de um STL, 100% headless (matplotlib).

Renderizador ortográfico próprio em 2D: o mplot3d não tem z-buffer e ordena
polígonos inteiros de forma não confiável — em malhas grandes a superfície sai
"rasgada". Aqui cada vista projeta os triângulos, ordena por profundidade
(painter, do fundo para a frente) e desenha com PolyCollection 2D; a borda de
cada triângulo recebe a cor da face para o antialiasing não abrir frestas.

Uso: preview_stl.py <arquivo.stl> <pasta-de-saida>
"""
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import trimesh
from matplotlib.collections import PolyCollection

MAX_FACES = 300000  # acima disso, simplifica (limite generoso: o 2D aguenta)


def matriz_iso(azim_graus: float = -60.0, elev_graus: float = 30.0) -> np.ndarray:
    """Linhas = eixos da câmera no mundo: direita, cima, para-o-observador."""
    a, e = np.radians(azim_graus), np.radians(elev_graus)
    olho = np.array([np.cos(e) * np.cos(a), np.cos(e) * np.sin(a), np.sin(e)])
    direita = np.cross([0.0, 0.0, 1.0], olho)
    direita /= np.linalg.norm(direita)
    cima = np.cross(olho, direita)
    return np.array([direita, cima, olho])


# (matriz, rótulo eixo horizontal, rótulo eixo vertical)
VISTAS = {
    "topo": (np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]], float), "X", "Y"),
    "frente": (np.array([[1, 0, 0], [0, 0, 1], [0, -1, 0]], float), "X", "Z"),
    "tras": (np.array([[-1, 0, 0], [0, 0, 1], [0, 1, 0]], float), "-X", "Z"),
    "direita": (np.array([[0, 1, 0], [0, 0, 1], [1, 0, 0]], float), "Y", "Z"),
    "esquerda": (np.array([[0, -1, 0], [0, 0, 1], [-1, 0, 0]], float), "-Y", "Z"),
    "iso": (matriz_iso(), "", ""),
}
LUZ_CAMERA = np.array([0.35, 0.5, 0.79])  # fixa no referencial de quem olha
COR_BASE = np.array([0.45, 0.65, 0.95])


def main(stl: str, out_dir: str) -> None:
    os.makedirs(out_dir, exist_ok=True)
    mesh = trimesh.load(stl, force="mesh")
    if len(mesh.faces) > MAX_FACES:
        try:
            mesh = mesh.simplify_quadric_decimation(face_count=MAX_FACES)
        except BaseException:
            pass  # preview com malha cheia, só fica mais lento

    dim = mesh.bounds[1] - mesh.bounds[0]

    # painter ordena por profundidade média: triângulo grande (topo de placa)
    # atravessa faixas de profundidade e sai da ordem — subdividir limita o
    # tamanho e torna a ordenação confiável
    try:
        from trimesh.remesh import subdivide_to_size

        v, f = subdivide_to_size(
            mesh.vertices, mesh.faces, max_edge=float(np.linalg.norm(dim)) / 15
        )
        mesh = trimesh.Trimesh(v, f, process=False)
    except BaseException:
        pass

    tris = mesh.triangles  # (n, 3, 3)
    normais = mesh.face_normals

    for nome, (rot, rot_h, rot_v) in VISTAS.items():
        cam = tris @ rot.T  # vértices no referencial da câmera
        tela = cam[:, :, :2]
        profundidade = cam[:, :, 2].mean(axis=1)
        ordem = np.argsort(profundidade)  # fundo primeiro (painter)

        # sombreamento bilateral: malha fechada, faces de costas ficam ocultas,
        # mas o abs evita manchas pretas se a ordenação falhar em algum ponto
        brilho = np.abs(normais @ rot.T @ LUZ_CAMERA) * 0.55 + 0.33
        # tom por altura: superfícies paralelas em alturas diferentes (relevo
        # sobre placa) têm a mesma normal e sumiriam nas vistas de frente
        faixa = profundidade.max() - profundidade.min()
        if faixa > 1e-9:
            brilho += ((profundidade - profundidade.min()) / faixa - 0.5) * 0.16
        cores = np.clip(brilho[:, None] * COR_BASE[None, :], 0, 1)

        larg = tela[:, :, 0].max() - tela[:, :, 0].min()
        alt = tela[:, :, 1].max() - tela[:, :, 1].min()
        prop = alt / max(larg, 1e-9)
        fig_l = 8.0
        fig_a = float(np.clip(fig_l * prop, 2.2, 8.0)) + 0.7  # +espaço do título
        fig, ax = plt.subplots(figsize=(fig_l, fig_a), dpi=110)

        pc = PolyCollection(
            tela[ordem],
            facecolors=cores[ordem],
            edgecolors=cores[ordem],  # borda = face: sem frestas de antialiasing
            linewidths=0.15,
        )
        ax.add_collection(pc)
        ax.autoscale()
        ax.set_aspect("equal")
        ax.set_xlabel(f"{rot_h} (mm)" if rot_h else "")
        ax.set_ylabel(f"{rot_v} (mm)" if rot_v else "")
        if nome == "iso":
            ax.set_xticks([])
            ax.set_yticks([])
        ax.set_title(f"{nome} — {dim[0]:.1f} x {dim[1]:.1f} x {dim[2]:.1f} mm")
        fig.savefig(os.path.join(out_dir, f"{nome}.png"), bbox_inches="tight")
        plt.close(fig)

    print(f"6 previews gerados em {out_dir}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
