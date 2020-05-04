using Plots
import Base.Iterators: countfrom
 
function SIR_simulation(population_size, infection_probability)
    statuses = fill("susceptible", population_size, 1)
    statuses[1, 1] = "infectious"
    transmissions = []
    for t in countfrom(2)
        n_infectious = sum(statuses[:, t-1] .== "infectious")
        if n_infectious == 0
            break
        end
        statuses = [statuses fill("susceptible", population_size)]
        for k in 1:population_size
            if statuses[k, t-1] == "recovered" || statuses[k, t-1] == "infectious"
                statuses[k, t] = "recovered"
            end
        end
        for j in 1:population_size
            if statuses[j, t-1] == "infectious"
                for k in 1:population_size
                    if statuses[k, t-1] == "susceptible"
                        if rand() < infection_probability
                            push!(transmissions, [(j, t-1),(k, t)])
                            statuses[k, t] = "infectious"
                        end
                    end
                end
            end
        end
    end
    statuses, transmissions
end