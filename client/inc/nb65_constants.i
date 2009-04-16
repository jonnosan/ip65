;constants for accessing the NB65 API file
;to use this file under CA65, then add "  .define EQU     =" to your code before this file is included.


NB65_API_VERSION_NUMBER  EQU $01


NB65_CART_SIGNATURE              EQU $8009
NB65_API_VERSION                 EQU $800d
NB65_BANKSWITCH_SUPPORT          EQU $800e
NB65_DISPATCH_VECTOR             EQU $800f 
NB65_PERIODIC_PROCESSING_VECTOR  EQU $8012
NB65_VBL_VECTOR                  EQU $8015
NB65_RAM_STUB_SIGNATURE          EQU $C000
NB65_RAM_STUB_ACTIVATE           EQU $C004

;function numbers
;to make a function call:
; Y  EQU function number
; AX  EQU pointer to parameter buffer (for functions that take parameters)
; then JSR NB65_DISPATCH_VECTOR
; on return, carry flag is set if there is an error, or clear otherwise
; some functions return results in AX directly, others will update the parameter buffer they were called with.
; any register not specified in outputs will have an undefined value on exit

NB65_INITIALIZE                EQU $01 ;no inputs or outputs - initializes IP stack, also sets IRQ chain to call NB65_VBL_VECTOR at @ 60hz
NB65_GET_IP_CONFIG             EQU $02 ;no inputs, outputs AX=pointer to IP configuration structure
NB65_DEACTIVATE                EQU $0F ;inputs: none, outputs: none (removes call to NB65_VBL_VECTOR on IRQ chain)

NB65_UDP_ADD_LISTENER          EQU $10 ;inputs: AX points to a UDP listener parameter structure, outputs: none
NB65_GET_INPUT_PACKET_INFO     EQU $11 ;inputs: AX points to a UDP packet parameter structure, outputs: UDP packet structure filled in
NB65_SEND_UDP_PACKET           EQU $12 ;inputs: AX points to a UDP packet parameter structure, outputs: none packet is sent

NB65_TFTP_DIRECTORY_LISTING    EQU $20 ;inputs: AX points to a TFTP parameter structure, outputs: none
NB65_TFTP_DOWNLOAD             EQU $21 ;inputs: AX points to a TFTP parameter structure, outputs: TFTP param structure updated with 
                                       ;NB65_TFTP_POINTER updated to reflect actual load address (if load address $0000 originally passed in)
NB65_TFTP_CALLBACK_DOWNLOAD    EQU $22 ;inputs: AX points to a TFTP parameter structure, outputs: none
NB65_TFTP_CALLBACK_UPLOAD      EQU $23 ;upload: AX points to a TFTP parameter structure, outputs: none

NB65_DNS_RESOLVE               EQU $30 ;inputs: AX points to a DNS parameter structure, outputs: DNS param structure updated with 
                                   ;NB65_DNS_HOSTNAME_IP updated with IP address corresponding to hostname.


NB65_PRINT_ASCIIZ              EQU $80 ;inputs: AX=pointer to null terminated string to be printed to screen, outputs: none
NB65_PRINT_HEX                 EQU $81 ;inputs: A=byte digit to be displayed on screen as (zero padded) hex digit, outputs: none
NB65_PRINT_DOTTED_QUAD         EQU $82 ;inputs: AX=pointer to 4 bytes that will be displayed as a decimal dotted quad (e.g. 192.168.1.1)
NB65_PRINT_IP_CONFIG           EQU $83 ;no inputs, no outputs, prints to screen current IP configuration


NB65_GET_LAST_ERROR            EQU $FF ;no inputs, outputs A  EQU error code (from last function that set the global error value, not necessarily the
                                   ;last function that was called)

;offsets in IP configuration structure (used by NB65_GET_IP_CONFIG)
NB65_CFG_MAC         EQU $00     ;6 byte MAC address
NB65_CFG_IP          EQU $06     ;4 byte local IP address (will be overwritten by DHCP)
NB65_CFG_NETMASK     EQU $0A     ;4 byte local netmask (will be overwritten by DHCP)
NB65_CFG_GATEWAY     EQU $0E     ;4 byte local gateway (will be overwritten by DHCP)
NB65_CFG_DNS_SERVER  EQU $12     ;4 byte IP address of DNS server (will be overwritten by DHCP)
NB65_CFG_DHCP_SERVER  EQU $16    ;4 byte IP address of DHCP server (will only be set by DHCP initialisation)
NB65_DRIVER_NAME     EQU $1A     ;2 byte pointer to name of driver

;offsets in TFTP parameter structure (used by NB65_TFTP_DIRECTORY_LISTING & NB65_TFTP_DOWNLOAD)
NB65_TFTP_IP         EQU $00                     ;4 byte IP address of TFTP server
NB65_TFTP_FILENAME   EQU $04                     ;2 byte pointer to asciiz filename (or filemask in case of NB65_TFTP_DIRECTORY_LISTING)
NB65_TFTP_POINTER    EQU $06                     ;2 byte pointer to memory location data to be stored in OR address of callback function

;offsets in DNS parameter structure (used by NB65_DNS_RESOLVE)
NB65_DNS_HOSTNAME    EQU $00                         ;2 byte pointer to asciiz hostname to resolve (can also be a dotted quad string)
NB65_DNS_HOSTNAME_IP EQU $00                         ;4 byte IP address (filled in on succesful resolution of hostname)

;offsets in UDP listener parameter structure
NB65_UDP_LISTENER_PORT      EQU $00                       ;2 byte port number
NB65_UDP_LISTENER_CALLBACK  EQU $02                       ;2 byte address of routine to call when UDP packet arrives for specified port

;offsets in UDP packet parameter structure
NB65_REMOTE_IP       EQU $00                          ;4 byte IP address of remote machine (src of inbound packets, dest of outbound packets)
NB65_REMOTE_PORT     EQU $04                          ;2 byte port number of remote machine (src of inbound packets, dest of outbound packets)
NB65_LOCAL_PORT      EQU $06                          ;2 byte port number of local machine (src of outbound packets, dest of inbound packets)
NB65_PAYLOAD_LENGTH  EQU $08                          ;2 byte length of payload of packet (after all ethernet,IP,UDP headers)
NB65_PAYLOAD_POINTER EQU $0A                          ;2 byte pointer to payload of packet (after all headers)

;error codes (as returned by NB65_GET_LAST_ERROR)
NB65_ERROR_PORT_IN_USE                    EQU $80
NB65_ERROR_TIMEOUT_ON_RECEIVE             EQU $81
NB65_ERROR_TRANSMIT_FAILED                EQU $82
NB65_ERROR_TRANSMISSION_REJECTED_BY_PEER  EQU $83
NB65_ERROR_INPUT_TOO_LARGE                EQU $84
NB65_ERROR_DEVICE_FAILURE                 EQU $85
NB65_ERROR_ABORTED_BY_USER                EQU $86
NB65_ERROR_OPTION_NOT_SUPPORTED           EQU $FE
NB65_ERROR_FUNCTION_NOT_SUPPORTED         EQU $FF