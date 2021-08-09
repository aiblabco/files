import os

c = get_config()
c.Spawner.cmd = "/home/kampnote/mambaforge/bin/jupyter-labhub"
c.Spawner.default_url = "/lab"
c.JupyterHub.spawner_class = "sudospawner.SudoSpawner"
c.JupyterHub.logo_file = "/home/kampnote/mambaforge/share/jupyterhub/static/images/kampnote.png"
c.JupyterHub.authenticator_class = 'kampauth'
c.KampAuthenticator.user = 'kampuser'
c.KampAuthenticator.allowedUsername = '{CMPUSER}'
c.KampAuthenticator.loginUrl = 'http://133.186.221.12:8080/login'
c.KampAuthenticator.mountUrl = 'http://133.186.221.12:8080/mount'