{#
  WARNING: This example is not up to date. Please stay tuned for updates.
#}

opennebula:
  lookup:
    controller:
      config:
        oned_conf:
          template_path: False
        one_auth:
          manage: True
          content: 'oneadmin:myinitialpasswhichwillbechangedafterfirstlogin'
    sunstone:
      config:
        sunstone_server:
          content:
            :tmpdir: /var/tmp
            :one_xmlrpc: http://localhost:2633/RPC2
            :host: 0.0.0.0
            :port: 9869
            :sessions: memory
            :memcache_host: localhost
            :memcache_port: 11211
            :memcache_namespace: opennebula.sunstone
            :debug_level: 3
            :auth: sunstone
            :core_auth: cipher
            :vnc_proxy_port: 29876
            :vnc_proxy_support_wss: no
            :vnc_proxy_cert:
            :vnc_proxy_key:
            :vnc_proxy_ipv6: false
            :lang: en_US
            :table_order: desc
            :marketplace_url: http://marketplace.c12g.com/appliance
            :oneflow_server: http://localhost:2474/
            :routes:
              - oneflow
        sunstone_views:
          manage: True
          content:
            logo: images/opennebula-sunstone-v4.0.png
            available_tabs:
                - dashboard-tab
                - system-tab
                - users-tab
                - groups-tab
                - acls-tab
                - vresources-tab
                - vms-tab
                - templates-tab
                - images-tab
                - files-tab
                - infra-tab
                - clusters-tab
                - hosts-tab
                - datastores-tab
                - vnets-tab
                - zones-tab
                - provision-tab
            groups:
                oneadmin:
                    - admin
                    - vdcadmin
                    - user
                    - cloud
            default:
                - cloud
  datastores:
    - name: /var/lib/one/datastores/1
      type: nfs
      source: mycontroller.domain.local:/var/lib/one/datastores/1
    - name: /var/lib/one/datastores/2
      type: nfs
      source: mycontroller.domain.local:/var/lib/one/datastores/2


{# Collect oneadmin's sshpubkey on the controller and deploy on e.g. compute_node #}
opennebula:
  salt:
    collect:
      - controller_sshpubkey

    {# A specific host #}
    collect_controller_sshpubkey:
      tgt: mycontroller.domain.local
      fun: cmd.run_stdout

    {# A set of specfic hosts #}
    collect_controller_sshpubkey:
      tgt: I@environment:prod and G@roles:opennebula_controller
      fun: cmd.run_stdout
      exprform: compound

{# ... or specifiy oneadmin's sshpubkey manually #}
oneadmin:
  lookup:
    oneadmin:
      controller_sshpubkeys:
        mycontroller: AAAAB3NzaC1yc2EAAA..


mine_functions: {# <= yes, this is an arbitrary pillar too! #}
  cmd.run_stdout:
    - 'test -r /var/lib/one/.ssh/id_rsa.pub && cat /var/lib/one/.ssh/id_rsa.pub'

{# Collect host list to set static host lookup (/etc/hosts) #}
opennebula:
  salt:
    collect:
      - hostlist
    collect_hostlist:
      tgt: I@environment:prod and ( G@roles:opennebula_controller or G@roles:opennebula_compute_node ) and not G@fqdn:{{ salt['grains.get']('fqdn', 'grainsnotavailableyoushouldfixthat') }}

{# Collect host list and their SSH host keys to oneadmin's known_host list #}
opennebula:
  salt:
    collect:
      - hostspubkey
    collect_hostspubkey:
      tgt: I@environment:prod and ( G@roles:opennebula_controller or G@roles:opennebula_compute_node )

{# Manage ssh configuration of oneadmin user #}
opennebula:
  lookup:
    oneadmin:
      sshconfig:
        manage: True
  salt:
    collect:
      - host_names
    collect_host_names:
      tgt: I@environment:prod and ( G@roles:opennebula_controller or G@roles:opennebula_compute_node ) and G@teams:one_nc1
