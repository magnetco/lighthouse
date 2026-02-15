import SwiftUI

struct ProjectMappingsView: View {
    @ObservedObject var viewModel: PortViewModel
    @State private var showingAddProject = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Project Mappings")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Auto-group ports by project name")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Button {
                    showingAddProject = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.accent)
                }
                .buttonStyle(.plain)
                .help("Add project")
            }
            .padding()
            .background(Theme.headerGradient)
            
            SolidDivider()
            
            // Project list
            if viewModel.projectMappings.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.projectMappings) { mapping in
                            ProjectMappingRow(
                                mapping: mapping,
                                onToggle: {
                                    var updated = mapping
                                    updated.isEnabled.toggle()
                                    viewModel.updateProjectMapping(updated)
                                },
                                onEdit: { updated in
                                    viewModel.updateProjectMapping(updated)
                                },
                                onRemove: {
                                    viewModel.removeProjectMapping(id: mapping.id)
                                }
                            )
                            
                            if mapping.id != viewModel.projectMappings.last?.id {
                                SolidDivider()
                            }
                        }
                    }
                }
            }
            
            SolidDivider()
            
            // Footer
            HStack {
                Text("\(viewModel.projectMappings.count) projects")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textTertiary)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.headerBackground)
        }
        .frame(width: 500, height: 450)
        .background(Theme.windowBackground)
        .sheet(isPresented: $showingAddProject) {
            AddProjectMappingSheet { mapping in
                viewModel.addProjectMapping(mapping)
                showingAddProject = false
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 32))
                .foregroundColor(Theme.textMuted)
            
            Text("No project mappings")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
            
            Text("Add projects to automatically group your dev servers")
                .font(.system(size: 10))
                .foregroundColor(Theme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }
}

struct ProjectMappingRow: View {
    let mapping: ProjectMapping
    let onToggle: () -> Void
    let onEdit: (ProjectMapping) -> Void
    let onRemove: () -> Void
    
    @State private var isHovering = false
    @State private var isEditing = false
    @State private var editingName = ""
    @State private var editingPatterns = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Project icon
            Image(systemName: mapping.icon ?? "folder.fill")
                .font(.system(size: 14))
                .foregroundColor(Theme.iconDefault)
                .frame(width: 24)
            
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isHovering ? Theme.hoverBackground : Color.clear)
        .onHover { isHovering = $0 }
    }
    
    private var displayView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(mapping.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                
                Text(mapping.patterns.joined(separator: ", "))
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button {
                    startEditing()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.iconDefault)
                }
                .buttonStyle(.plain)
                .help("Edit")
                
                Toggle("", isOn: Binding(
                    get: { mapping.isEnabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(0.7)
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.error)
                }
                .buttonStyle(.plain)
                .help("Remove")
            }
        }
    }
    
    private var editingView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                TextField("Project name", text: $editingName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.inputBackground)
                    .cornerRadius(4)
                
                TextField("Patterns (comma separated)", text: $editingPatterns)
                    .textFieldStyle(.plain)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.inputBackground)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Button {
                    saveEdit()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.success)
                }
                .buttonStyle(.plain)
                .help("Save")
                
                Button {
                    cancelEdit()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Theme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Cancel")
            }
        }
    }
    
    private func startEditing() {
        editingName = mapping.name
        editingPatterns = mapping.patterns.joined(separator: ", ")
        isEditing = true
    }
    
    private func saveEdit() {
        let patterns = editingPatterns
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var updated = mapping
        updated.name = editingName.trimmingCharacters(in: .whitespaces)
        updated.patterns = patterns.isEmpty ? [ProjectMapping.generatePattern(from: updated.name)] : patterns
        
        onEdit(updated)
        isEditing = false
    }
    
    private func cancelEdit() {
        isEditing = false
    }
}

struct AddProjectMappingSheet: View {
    let onAdd: (ProjectMapping) -> Void
    
    @State private var name = ""
    @State private var patterns = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Project")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            }
            .padding()
            .background(Theme.headerGradient)
            
            SolidDivider()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Project Name")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    TextField("e.g., Enthusiast Auto", text: $name)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Theme.inputBackground)
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Match Patterns")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    TextField("e.g., enthusiast-auto, ea-website", text: $patterns)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Theme.inputBackground)
                        .cornerRadius(6)
                    
                    Text("Comma-separated folder name patterns to match")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textTertiary)
                }
            }
            .padding(20)
            
            Spacer()
            
            SolidDivider()
            
            // Footer
            HStack {
                Spacer()
                
                Button("Add Project") {
                    addProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Theme.headerBackground)
        }
        .frame(width: 400, height: 300)
        .background(Theme.windowBackground)
    }
    
    private func addProject() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let patternList = patterns
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let mapping = ProjectMapping(
            name: trimmedName,
            patterns: patternList
        )
        
        onAdd(mapping)
    }
}
