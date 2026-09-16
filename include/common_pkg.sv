// ============================================
// common_pkg.sv
// ============================================
package common_pkg;

    localparam HIGH = 1'b1;
    localparam LOW  = 1'b0;
    localparam TRIZ = 1'bz;
    localparam ON   = 1'b1;
    localparam OFF  = 1'b0;

    localparam pref_format = "[%12t]:";

    localparam msg_format = $sformatf("%s%s", pref_format, "%0s%0s%0s%0s%0s");

    typedef enum logic [1:0] { 
        SINGLE  = 2'b00,  
        DUAL    = 2'b01, 
        QUAD    = 2'b10,
        UNKNOWN = 2'b11 
    } IO_MODE_TYPE;

    typedef struct {
        reg [0:0] on_off;
        reg [15:0] addr;
        reg [31:0] rdata;
        reg [31:0] def_data;
        string name;
        string full_name;
    } REG_eSPI_TYPE;

    typedef struct {
        logic [15:0] addr;
        logic [7:0] response;
        logic [31:0] data;
        logic [15:0] sts;
        logic [7:0] crc;
        string reg_name;
    } T_ESPI_CONFIG_REGS;

    typedef struct {
        logic [7:0] response;
        logic [15:0] sts;
        logic [7:0] crc;
    } T_ESPI_GET_STATUS_REGS;

    typedef enum integer {
        APB     = 0,
        AHBL    = 1,
        NULL    = 2 
    } USER_INTERFACE_TYPE;


    // eSPI Command Opcode
    typedef enum logic [7:0] { 
        ESPI_PUT_PC         = 8'h00,
        ESPI_PUT_NP         = 8'h02,
        ESPI_GET_PC         = 8'h01,
        ESPI_GET_NP         = 8'h03,
        ESPI_PUT_IORD_S1    = 8'h40,
        ESPI_PUT_IORD_S2    = 8'h41,
        ESPI_PUT_IORD_S4    = 8'h43,
        ESPI_PUT_IOWR_S1    = 8'h44,
        ESPI_PUT_IOWR_S2    = 8'h45,
        ESPI_PUT_IOWR_S4    = 8'h47,
        ESPI_PUT_MRD32_S1   = 8'h48,
        ESPI_PUT_MRD32_S2   = 8'h49,
        ESPI_PUT_MRD32_S4   = 8'h4B,
        ESPI_PUT_MWR32_S1   = 8'h4C,
        ESPI_PUT_MWR32_S2   = 8'h4D,
        ESPI_PUT_MWR32_S4   = 8'h4F,
        ESPI_PUT_VWIRE      = 8'h04,
        ESPI_GET_VWIRE      = 8'h05,
        ESPI_PUT_OOB        = 8'h06,
        ESPI_GET_OOB        = 8'h07,
        ESPI_PUT_FLASH_C    = 8'h08,
        ESPI_GET_FLASH_NP   = 8'h09,
        ESPI_GET_STATUS     = 8'h25,
        ESPI_SET_CONFIG     = 8'h22,
        ESPI_GET_CONFIG     = 8'h21,
        ESPI_RESET          = 8'hFF 
    } ESPI_CMD_OPCODE_TYPE;

    // ADDRESSES - ESPI MMR REGISTERS
    typedef enum logic [15:0] {
        DEVICE_IDENTIFICATION_ADDR   = 16'h004,
        GEN_CAP_CFG_ADDR             = 16'h008,
        CHO_CAP_CFG_ADDR             = 16'h010,
        CH1_CAP_CFG_ADDR             = 16'h020,
        CH2_CAP_CFG_ADDR             = 16'h030,
        CH3_CAP_CFG_ADDR             = 16'h040 
    } ESPI_MMR_REGS_TYPE;

    function string get_espi_mmr_reg_name(input [15:0] x);
        ESPI_MMR_REGS_TYPE dummy;
        if ($cast(dummy, x)) return $sformatf("%s", dummy);
        return "RESERVED";
    endfunction

endpackage
