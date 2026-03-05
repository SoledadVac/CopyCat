import SwiftUI

struct QueryResultTable: View {
    let result: QueryResult?
    
    var body: some View {
        if let result = result {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(result.columns, id: \.self) { column in
                        Text(column)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(NSColor.controlBackgroundColor))
                    }
                }
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(result.rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(row, id: \.self) { cell in
                                    Text(cell)
                                        .font(.body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                }
                            }
                            Divider()
                        }
                    }
                }
                
                HStack {
                    Text("\(result.rows.count) 行")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "耗时: %.3f 秒", result.executionTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .border(Color(NSColor.separatorColor), width: 1)
            .cornerRadius(4)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "tablecells")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("执行查询以查看结果")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
