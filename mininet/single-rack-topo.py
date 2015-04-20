#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import CPULimitedHost, Controller, OVSSwitch, RemoteController
from mininet.link import TCLink
from mininet.util import irange,dumpNodeConnections
from mininet.log import setLogLevel
from mininet.topo import SingleSwitchTopo
from mininet.cli import CLI

def int2dpid( dpid ):
   try:
      dpid = hex( dpid )[ 2: ]
      dpid = '0' * ( 16 - len( dpid ) ) + dpid
      return dpid
   except IndexError:
      raise Exception( 'Unable to derive default datapath ID - '
                       'please either specify a dpid or use a '
               'canonical switch name such as s23.' )


def int2mac( mac ):
   try:
      mac = hex( mac )[ 2: ]
      mac = '0' * ( 12 - len( mac ) ) + mac
      return mac
   except IndexError:
      raise Exception( 'Unable to derive default MAC - '
                       'please either specify a mac or use a '
               'canonical mac address.' )


def perfTest():
    '''
    Create a network from semi-scratch with multiple controllers, and run perf test
    '''
    net = Mininet( switch = OVSSwitch, build = False, listenPort=6634 )

    print "*** Creating (reference) controllers"
    #c1 = net.addController('c1', controller = RemoteController, ip = '141.212.108.10', port = 6633)
    c1 = net.addController('c1', controller = RemoteController, ip = '141.212.108.10', port = 6653)
#    c2 = net.addController('c2', controller = RemoteController, ip = '141.212.108.5', port = 6645)

    print "*** Creating switches"
    s1 = net.addSwitch( 's1', dpid=int2dpid(1) )

    print "*** Creating hosts"
    #hosts1 = [ net.addHost( 'h%d' % n ) for n in range(1, 49) ]
    hosts1 = [ net.addHost('h%d' % n, ip='10.0.0.%d' % n, mac=int2mac(n)) for n in range(1, 49) ]   

    print "*** Creating links"
    for h in hosts1:
        net.addLink( s1, h )

    print "*** Starting network"
    net.build()
    c1.start()
#    s1.start( [ c1, c2 ] )
    s1.start( [ c1 ] );
 
    #print "*** Testing network"    
#    for h in net.hosts:
    for x in range(1, 41):
        h = net.get( 'h%d' % x )
        h.cmd('./start_shuffle.sh');
   
    print "*** Scanning ports"
    for x in [ 41 ]: #, 43, 44, 45, 46, 47, 48 ]: #range(41, 49):
        h1 = net.get('h%d' % x )
        h1.cmd('./start_port_scan.sh');

    print "*** Running CLI"
    CLI( net )

    print "*** Stopping network"
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    perfTest()

