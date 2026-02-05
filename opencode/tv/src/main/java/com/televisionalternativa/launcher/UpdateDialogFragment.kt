package com.televisionalternativa.launcher

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import com.google.android.material.R

/**
 * Fragmento de Dialogo para el Panel de Control del Sistema.
 * Se lanza al tocar el botón de versión en el header.
 */
class UpdateDialogFragment : DialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?) {
        super.onCreateDialog(savedInstanceState)
        isCancelable = true // Se puede cerrar tocando fuera
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?): View {
        val view = inflater.inflate(R.layout.fragment_update_dialog, container, false)

        // Referencias a los componentes visuales
        val btnCheck = view.findViewById<Button>(R.id.btn_check_updates)
        val btnClose = view.findViewById<Button>(R.id.btn_close_panel)
        val tvStatus = view.findViewById<TextView>(R.id.tv_update_status)

        // Botón principal: Buscar actualizaciones
        btnCheck.setOnClickListener {
            // TODO: Aquí se llamaría a tu backend real para buscar nuevas versiones
            // Por ahora, simulamos que se encontró una actualización
            
            tvStatus.text = "Actualización encontrada: v1.1.0"
            tvStatus.setTextColor(resources.getColor(R.color.gold))
        }

        // Botón de cerrar
        btnClose.setOnClickListener {
            dismiss()
        }

        return view
    }

    companion object {
        fun newInstance(): UpdateDialogFragment {
            return UpdateDialogFragment()
        }
    }
}
