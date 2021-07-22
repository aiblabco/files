import os

c = get_config()
c.Spawner.cmd = "/home/kampnote/mambaforge/bin/jupyter-labhub"
c.Spawner.default_url = "/lab"
c.JupyterHub.spawner_class = "sudospawner.SudoSpawner"
c.JupyterHub.logo_file = "/home/kampnote/mambaforge/share/jupyterhub/static/images/kampnote.png"