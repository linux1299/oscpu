// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


void Vtop__traceChgSub0(Vtop* vlSelf, VerilatedVcd* tracep);

void Vtop__traceChgTop0(void* voidSelf, VerilatedVcd* tracep) {
    Vtop* const __restrict vlSelf = static_cast<Vtop*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        Vtop__traceChgSub0(vlSymsp->TOPp, tracep);
    }
}

void Vtop__traceChgSub0(Vtop* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgBit(oldp+0,(vlSelf->in_a));
        tracep->chgBit(oldp+1,(vlSelf->in_b));
        tracep->chgBit(oldp+2,(vlSelf->out_s));
        tracep->chgBit(oldp+3,(vlSelf->out_c));
    }
}

void Vtop__traceCleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    Vtop* const __restrict vlSelf = static_cast<Vtop*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        __Vm_traceActivity[0U] = 0U;
    }
}
